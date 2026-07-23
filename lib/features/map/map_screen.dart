import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/geocoding_service.dart';
import '../../models/pin_model.dart';
import '../profile/profile_screen.dart';
import 'package:travel_planner/l10n/app_localizations.dart';

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
  List<LatLng> _routePoints = []; 
  Color _routeColor = Colors.blue;

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
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationServicesDisabled)));
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDenied)));
          setState(() => _isLocating = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDeniedForever)));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationFetchFailed)));
    }
  }

  Future<void> _showPinDialog({LatLng? point, PinModel? existingPin, String? suggestedTitle}) async {
    final TextEditingController titleController = TextEditingController(text: existingPin?.title ?? suggestedTitle ?? '');
    final TextEditingController noteController = TextEditingController(text: existingPin?.note ?? '');
    
    final List<Color> dialogColors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal,
    ];
    Color selectedColor = existingPin != null ? Color(existingPin.color) : Colors.red;
    
    XFile? selectedImage;
    bool isUploading = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingPin == null ? AppLocalizations.of(context)!.mapAddPlaceTitle : AppLocalizations.of(context)!.mapEditPlaceTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.placeNameHint, labelText: AppLocalizations.of(context)!.placeNameLabel),
                      autofocus: existingPin == null && suggestedTitle == null,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isUploading,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(hintText: AppLocalizations.of(context)!.placeNoteHint, labelText: AppLocalizations.of(context)!.placeNoteLabel),
                      maxLines: 3,
                      enabled: !isUploading,
                    ),
                    const SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: isUploading ? null : () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1080, 
                          imageQuality: 85, 
                        );
                        if (image != null) {
                          setStateDialog(() => selectedImage = image);
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[400]!, width: 1, style: BorderStyle.solid),
                          image: selectedImage != null 
                              ? DecorationImage(
                                  image: kIsWeb 
                                      ? NetworkImage(selectedImage!.path) as ImageProvider
                                      : FileImage(File(selectedImage!.path)), 
                                  fit: BoxFit.cover
                                )
                              : (existingPin?.imageUrl != null && existingPin!.imageUrl!.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(existingPin.imageUrl!), fit: BoxFit.cover) 
                                  : null),
                        ),
                        child: selectedImage == null && (existingPin?.imageUrl == null || existingPin!.imageUrl!.isEmpty)
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                                    const SizedBox(height: 8),
                                    Text(AppLocalizations.of(context)!.addPhotoLabel, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(AppLocalizations.of(context)!.selectPinColorLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (var color in dialogColors)
                          GestureDetector(
                            onTap: isUploading ? null : () => setStateDialog(() => selectedColor = color),
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

                    if (isUploading) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8), 
                      Center(child: Text(AppLocalizations.of(context)!.processingDataWait, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.blue))),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context, null), 
                  child: Text(AppLocalizations.of(context)!.cancelButton)
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: selectedColor, foregroundColor: Colors.white),
                  onPressed: isUploading ? null : () async {
                    if (titleController.text.trim().isEmpty) return; 
                    
                    setStateDialog(() => isUploading = true);
                    
                    String? finalImageUrl = existingPin?.imageUrl;
                    String? fetchedAddress = existingPin?.address;

                    try {
                      if (selectedImage != null) {
                        final bytes = await selectedImage!.readAsBytes();
                        final String fileName = 'pins/${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        final Reference ref = FirebaseStorage.instance.ref().child(fileName);
                        
                        final UploadTask uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
                        final TaskSnapshot snapshot = await uploadTask;
                        finalImageUrl = await snapshot.ref.getDownloadURL(); 
                      }

                      if (fetchedAddress == null) {
                         double targetLat = point?.latitude ?? existingPin!.latitude;
                         double targetLon = point?.longitude ?? existingPin!.longitude;
                         fetchedAddress = await _geocodingService.getAddressFromCoordinates(targetLat, targetLon);
                      }
                      
                    } catch (e) {
                      developer.log('Hata: $e', name: 'MapScreen');
                    } finally {
                      if (mounted) setStateDialog(() => isUploading = false);
                    }

                    if (mounted) {
                      Navigator.pop(context, {
                        'title': titleController.text.trim(),
                        'note': noteController.text.trim(),
                        'color': selectedColor.value,
                        'imageUrl': finalImageUrl, 
                        'address': fetchedAddress, 
                      });
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.saveButton),
                ),
              ],
            );
          }
        );
      },
    );

    if (result != null) {
      if (existingPin == null && point != null) {
        final newPin = PinModel(
          userId: _currentUserId, 
          title: result['title'], 
          note: result['note'].isEmpty ? null : result['note'], 
          color: result['color'], 
          latitude: point.latitude, 
          longitude: point.longitude, 
          createdAt: DateTime.now(),
          imageUrl: result['imageUrl'], 
          address: result['address'], 
        );
        try {
          await _databaseService.addPin(context, newPin);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.savedSuccessfully), backgroundColor: Colors.green));
          setState(() => _searchResults = []);
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred), backgroundColor: Colors.red));
        }
      } else if (existingPin != null) {
        final updatedPin = PinModel(
          id: existingPin.id, 
          userId: existingPin.userId, 
          title: result['title'], 
          note: result['note'].isEmpty ? null : result['note'], 
          color: result['color'], 
          latitude: existingPin.latitude, 
          longitude: existingPin.longitude, 
          createdAt: existingPin.createdAt,
          imageUrl: result['imageUrl'], 
          address: result['address'], 
        );
        try {
          await _databaseService.updatePin(context, updatedPin);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.updatedSuccessfully), backgroundColor: Colors.green));
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred), backgroundColor: Colors.red));
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
            
            if (pin.imageUrl != null && pin.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  pin.imageUrl!,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 130, width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 130, width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(pin.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(pin.color)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => setState(() => _openedPopupPin = null), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
            const Divider(),
            if (pin.note != null && pin.note!.isNotEmpty)
              Text(pin.note!, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 3, overflow: TextOverflow.ellipsis)
            else
              Text(AppLocalizations.of(context)!.noNoteAdded, style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
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
                        title: Text(AppLocalizations.of(context)!.areYouSure), 
                        content: Text(pin.imageUrl != null 
                            ? AppLocalizations.of(context)!.deletePlaceWithPhoto(pin.title) 
                            : AppLocalizations.of(context)!.deletePlaceOnly(pin.title)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancelButton)),
                          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context)!.deleteButton)),
                        ],
                      ),
                    );
                    if (confirm == true && pin.id != null) {
                      await _databaseService.deletePin(context, pin.id!);
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StreamBuilder<List<PinModel>>(
          stream: _databaseService.getUserPins(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
             final pins = snapshot.data!;
            if (pins.isEmpty) {
              return Center(
                child: Padding(padding: const EdgeInsets.all(24.0), child: Text(AppLocalizations.of(context)!.noSavedPlacesYet, style: const TextStyle(color: Colors.grey))),
              );
            }
            
            return Column(
              children: [
                 Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(AppLocalizations.of(context)!.mySavedPlaces, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                const Divider(height: 1, color: Colors.black12),
                Expanded(
                  child: ListView.builder(
                    itemCount: pins.length,
                    itemBuilder: (context, index) {
                      final pin = pins[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: pin.imageUrl != null && pin.imageUrl!.isNotEmpty
                            ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(pin.imageUrl!))
                            : CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(pin.color).withOpacity(0.15),
                                child: Icon(Icons.location_on, color: Color(pin.color), size: 26),
                              ),
                        title: Text(pin.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pin.note != null && pin.note!.isNotEmpty) ...[
                                Text(pin.note!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                const SizedBox(height: 4),
                              ],
                              Row(
                                children: [
                                  const Icon(Icons.place, size: 14, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pin.address ?? AppLocalizations.of(context)!.addressLoadingOrNotFound,
                                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w400),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.grey, size: 26),
                          onPressed: () {
                            Navigator.pop(context);
                            _showPinDialog(existingPin: pin);
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _mapController.move(pin.latLng, 16);
                        },
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

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = []; 
      _openedPopupPin = null; 
    });
    
    final bounds = _mapController.camera.visibleBounds; 
    final center = _mapController.camera.center;        
    
    List<SearchResult> results = await _geocodingService.searchPlace(query, bounds: bounds);
    if (results.isEmpty) results = await _geocodingService.searchPlace(query, biasLocation: center);
    if (results.isEmpty && query.contains(' ')) {
      final firstWord = query.split(' ').first;
      results = await _geocodingService.searchPlace(firstWord, biasLocation: center);
    }
    
    setState(() => _isSearching = false);

    if (results.isNotEmpty) {
      setState(() => _searchResults = results);
      if (results.length == 1) {
        _mapController.move(results.first.location, 15.0); 
      } else {
        _mapController.move(results.first.location, 11.5); 
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.placeNotFoundLongPress), backgroundColor: Colors.orange, duration: const Duration(seconds: 4)));
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
              point: _openedPopupPin!.latLng, width: 250, height: 350, alignment: Alignment.center, 
              child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 25.0), child: _buildPinPopup(_openedPopupPin!))),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myTravelMapTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.blue),
                tooltip: AppLocalizations.of(context)!.myProfileTooltip,
              onPressed: () async {
  final dynamic result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
  );

  if (result != null) {
    setState(() {
      _routePoints.clear(); 
    });

    if (result is Map && result['isRoute'] == true) {
      final List dayPins = result['pins'];
      if (dayPins.isNotEmpty) {
        try {
          List<LatLng> safeRoutePoints = [];
          for (var pin in dayPins) {
            safeRoutePoints.add(LatLng(pin.latitude, pin.longitude));
          }  setState(() {
            _routePoints = safeRoutePoints;
            _routeColor = Color(result['themeColor']); 
          });
          
          _mapController.move(_routePoints.first, 13.0); 
        } catch (e) {
          debugPrint("Rota çizim hatası: $e");
        }
      }
    } 
    else if (result is List) {
       if (result.isNotEmpty) {
          try {
            List<LatLng> safeRoutePoints = [];
            for (var pin in result) {
              safeRoutePoints.add(LatLng(pin.latitude, pin.longitude));
            }
            setState(() {
              _routePoints = safeRoutePoints;
              _routeColor = Colors.blueAccent; 
            });
            _mapController.move(_routePoints.first, 13.0); 
          } catch (e) {
            debugPrint("Rota çizim hatası: $e");
          }
       }
    }
    else {
      try {
        _mapController.move(result as LatLng, 16.0);
      } catch (e) {
        _mapController.move(LatLng(result.latitude, result.longitude), 16.0);
      }
    }
  }
},
              ),
              IconButton(icon: const Icon(Icons.format_list_bulleted, color: Colors.blue), tooltip: AppLocalizations.of(context)!.savedPlacesTooltip, onPressed: _showPinListBottomSheet),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _authService.signOut(context);
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
      if (_routePoints.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: _routeColor, 
                    strokeWidth: 4.0,  
                  ),
                ],
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
                                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchCityOrPlaceHint, border: InputBorder.none, icon: const Icon(Icons.search, color: Colors.grey)),
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