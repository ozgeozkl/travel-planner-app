import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; 
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/geocoding_service.dart';
import '../../models/pin_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final GeocodingService _geocodingService = GeocodingService();
  
  final MapController _mapController = MapController(); 
  final TextEditingController _searchController = TextEditingController(); 
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _isSearching = false; 
  PinModel? _openedPopupPin;
  List<SearchResult> _searchResults = [];
  
  LatLng? _currentLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum servisleri kapalı.')));
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni verilmedi.')));
          setState(() => _isLocating = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izinleri kalıcı olarak reddedildi.')));
        setState(() => _isLocating = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final myLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = myLatLng;
        _isLocating = false;
      });

      _mapController.move(myLatLng, 14.0);
      
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum alınamadı.')));
    }
  }

  Future<void> _showPinDialog({LatLng? point, PinModel? existingPin, String? suggestedTitle}) async {
    final TextEditingController titleController = TextEditingController(text: existingPin?.title ?? suggestedTitle ?? '');
    final TextEditingController noteController = TextEditingController(text: existingPin?.note ?? '');
    
    final List<Color> dialogColors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal,
    ];

    Color selectedColor = existingPin != null ? Color(existingPin.color) : Colors.red;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingPin == null ? 'Yeni Yer Ekle' : 'Yeri Düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Mekan Adı (Zorunlu)', labelText: 'Mekan Adı'),
                      autofocus: existingPin == null && suggestedTitle == null,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(hintText: 'Buraya dair notlarınız...', labelText: 'Not (İsteğe Bağlı)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Pin Rengi Seçin:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (var color in dialogColors)
                          GestureDetector(
                            onTap: () {
                              setStateDialog(() => selectedColor = color);
                            },
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle,
                                border: Border.all(color: selectedColor.value == color.value ? Colors.black : Colors.transparent, width: selectedColor.value == color.value ? 3 : 0),
                              ),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('İptal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: selectedColor, foregroundColor: Colors.white),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return; 
                    Navigator.pop(context, {'title': titleController.text.trim(), 'note': noteController.text.trim(), 'color': selectedColor.value});
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          }
        );
      },
    );

    if (result != null) {
      if (existingPin == null && point != null) {
        final newPin = PinModel(userId: _currentUserId, title: result['title'], note: result['note'].isEmpty ? null : result['note'], color: result['color'], latitude: point.latitude, longitude: point.longitude, createdAt: DateTime.now());
        try {
          await _databaseService.addPin(newPin);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedildi!'), backgroundColor: Colors.green));
          setState(() => _searchResults = []);
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata oluştu.'), backgroundColor: Colors.red));
        }
      } else if (existingPin != null) {
        final updatedPin = PinModel(id: existingPin.id, userId: existingPin.userId, title: result['title'], note: result['note'].isEmpty ? null : result['note'], color: result['color'], latitude: existingPin.latitude, longitude: existingPin.longitude, createdAt: existingPin.createdAt);
        try {
          await _databaseService.updatePin(updatedPin);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Güncellendi!'), backgroundColor: Colors.green));
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata oluştu.'), backgroundColor: Colors.red));
        }
      }
      setState(() => _openedPopupPin = null);
    }
  }

  Widget _buildPinPopup(PinModel pin) {
    return Card(
      elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(12), width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(pin.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(pin.color)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => setState(() => _openedPopupPin = null), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
            const Divider(),
            if (pin.note != null && pin.note!.isNotEmpty)
              Text(pin.note!, style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 3, overflow: TextOverflow.ellipsis)
            else
              const Text('Not eklenmemiş.', style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _showPinDialog(existingPin: pin), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () async {
                    final bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Emin misiniz?'), content: Text('${pin.title} silinecek.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                        ],
                      ),
                    );
                    if (confirm == true && pin.id != null) {
                      await _databaseService.deletePin(pin.id!);
                      setState(() => _openedPopupPin = null);
                    }
                  },
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPinListBottomSheet() {
    setState(() => _openedPopupPin = null); 
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StreamBuilder<List<PinModel>>(
          stream: _databaseService.getUserPins(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final pins = snapshot.data ?? [];
            if (pins.isEmpty) return const Center(child: Text('Henüz kaydedilmiş yeriniz yok.'));

            return Column(
              children: [
                const Padding(padding: EdgeInsets.all(16.0), child: Text('Kaydettiğim Yerler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                Expanded(
                  child: ListView.builder(
                    itemCount: pins.length,
                    itemBuilder: (context, index) {
                      final pin = pins[index];
                      return Dismissible(
                        key: Key(pin.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Emin misiniz?'), content: Text('${pin.title} silinecek.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          if (pin.id != null) await _databaseService.deletePin(pin.id!);
                        },
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Color(pin.color), child: const Icon(Icons.location_on, color: Colors.white)),
                          title: Text(pin.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(pin.note ?? 'Haritada görmek için dokunun', maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () { Navigator.pop(context); _showPinDialog(existingPin: pin); }),
                          onTap: () { Navigator.pop(context); _mapController.move(pin.latLng, 15.0); },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- GLOBAL ZEKAYA SAHİP 3 AŞAMALI ARAMA MOTORU ---
  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = []; 
      _openedPopupPin = null; 
    });
    
    // Haritanın o anki durumunu al
    final bounds = _mapController.camera.visibleBounds; // Ekranın sınırları
    final center = _mapController.camera.center;        // Ekranın merkezi
    
    // 1. AŞAMA (KATI ARAMA): Sadece ekranın içinde gördüğün yerleri ara
    List<SearchResult> results = await _geocodingService.searchPlace(
      query, 
      bounds: bounds 
    );
    
    // 2. AŞAMA (YUMUŞAK ARAMA): Ekranda bulamadıysa, ekrandan dışarı taş ama merkeze yakın olanları getir
    if (results.isEmpty) {
      results = await _geocodingService.searchPlace(
        query, 
        biasLocation: center
      );
    }
    
    // 3. AŞAMA (KELİME KÖKÜ): Hala yoksa, belki "Zapata Burger" yerine sadece "Zapata" kayıtlıdır
    if (results.isEmpty && query.contains(' ')) {
      final firstWord = query.split(' ').first;
      results = await _geocodingService.searchPlace(
        firstWord, 
        biasLocation: center
      );
    }
    
    setState(() => _isSearching = false);

    if (results.isNotEmpty) {
      setState(() => _searchResults = results);
      
      // Dinamik Zoom Zekası (Sevdiğin özellik korundu)
      if (results.length == 1) {
        _mapController.move(results.first.location, 15.0); 
      } else {
        _mapController.move(results.first.location, 11.5); 
      }
      
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mekan bulunamadı. Haritaya UZUN BASARAK kendiniz ekleyebilirsiniz!'), 
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PinModel>>(
      stream: _databaseService.getUserPins(),
      builder: (context, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        List<PinModel> pins = snapshot.data ?? [];

        final List<Marker> savedMarkers = [
          for (var pin in pins)
            Marker(
              point: pin.latLng, width: 30, height: 30, alignment: Alignment.center,
              child: GestureDetector(onTap: () => setState(() => _openedPopupPin = pin), child: Icon(Icons.location_on, color: Color(pin.color), size: 28)),
            )
        ];

        if (_searchResults.isNotEmpty) {
          for (var result in _searchResults) {
            savedMarkers.add(
              Marker(
                point: result.location, width: 40, height: 40, alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _showPinDialog(point: result.location, suggestedTitle: result.name),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: const Icon(Icons.location_on, color: Colors.blue, size: 28),
                  ),
                ),
              ),
            );
          }
        }

        if (_currentLocation != null) {
          savedMarkers.add(
            Marker(
              point: _currentLocation!,
              width: 40, height: 40,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
              ),
            )
          );
        }

        if (_openedPopupPin != null) {
          savedMarkers.add(
            Marker(
              point: _openedPopupPin!.latLng, width: 250, height: 200, alignment: Alignment.center,
              child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 25.0), child: _buildPinPopup(_openedPopupPin!))),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seyahat Haritam', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.format_list_bulleted, color: Colors.blue), tooltip: 'Kaydedilen Yerler', onPressed: _showPinListBottomSheet),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
          body: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController, 
                    options: MapOptions(
                      initialCenter: const LatLng(41.0082, 28.9784),
                      initialZoom: 13.0,
                      onTap: (_, __) => setState(() { _openedPopupPin = null; _searchResults = []; }), 
                      onLongPress: (tapPosition, point) { setState(() => _openedPopupPin = null); _showPinDialog(point: point); },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.travel_planner',
                      ),
                      MarkerLayer(markers: savedMarkers), 
                    ],
                  ),
                  
                  Positioned(
                    top: 16, left: 16, right: 16,
                    child: Card(
                      elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(hintText: 'Şehir veya mekan ara...', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey)),
                                onSubmitted: (_) => _handleSearch(), 
                              ),
                            ),
                            if (_isSearching)
                              const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                            else
                              IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.blue), onPressed: _handleSearch),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white, foregroundColor: Colors.blue, onPressed: _getCurrentLocation,
            child: _isLocating ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
          ),
        );
      },
    );
  }
}