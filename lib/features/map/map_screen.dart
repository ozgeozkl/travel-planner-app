import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/routing_service.dart';
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
  final RoutingService _routingService = RoutingService();
  final GeocodingService _geocodingService = GeocodingService();
  
  final MapController _mapController = MapController(); 
  final TextEditingController _searchController = TextEditingController(); 

  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<LatLng> _routePoints = []; 
  
  bool _isLoadingRoute = false;
  bool _isSearching = false; 

  // ARAMA ÇUBUĞU FONKSİYONU
  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final result = await _geocodingService.searchPlace(query);
    setState(() => _isSearching = false);

    if (result != null) {
      _mapController.move(result, 15.0);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan bulunamadı.'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // VERİTABANINA PIN KAYDETME
  Future<void> _savePinToDatabase(String title, LatLng point) async {
    if (_currentUserId.isEmpty) return;

    final newPin = PinModel(
      userId: _currentUserId,
      title: title,
      latitude: point.latitude,
      longitude: point.longitude,
      createdAt: DateTime.now(),
    );

    try {
      await _databaseService.addPin(newPin);
      setState(() => _routePoints = []); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yer haritaya kaydedildi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydedilirken hata oluştu.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // HARİTAYA UZUN BASINCA MANUEL EKLEME
  Future<void> _handleLongPress(TapPosition tapPosition, LatLng point) async {
    final TextEditingController titleController = TextEditingController();

    final String? pinTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Yer Ekle'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Buranın adı ne?'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (pinTitle != null && pinTitle.trim().isNotEmpty) {
      await _savePinToDatabase(pinTitle.trim(), point);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PinModel>>(
      stream: _databaseService.getUserPins(),
      builder: (context, snapshot) {
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        List<PinModel> pins = snapshot.data ?? [];

        // KULLANICININ KAYDETTİĞİ PİNLER (KIRMIZI - ÖRNEK OLARAK TEK BİR PİN ATIYORUZ)
        final savedMarkers = <Marker>[];

        // İleride kendi pinlerini görmek istediğin için, Kadıköy'deki arama sonucunu
        // temsil eden tek bir kırmızı prototip pin ekliyorum.
        if (_searchController.text.isNotEmpty && _mapController.camera.zoom > 10) {
          savedMarkers.add(
            Marker(
              point: const LatLng(40.9904, 29.0270), // Kadıköy Rıhtım civarı örnek koordinat
              width: 120, height: 80,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)]),
                    child: const Text('Özel Konum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Seyahat Haritam', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
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
                      onLongPress: _handleLongPress,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.travel_planner',
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(points: _routePoints, color: Colors.blueAccent, strokeWidth: 5.0),
                          ],
                        ),
                      MarkerLayer(markers: savedMarkers), 
                    ],
                  ),
                  
                  // ARAMA ÇUBUĞU
                  Positioned(
                    top: 16, left: 16, right: 16,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          
          // ROTAYI ÇİZ BUTONU
          floatingActionButton: pins.length > 1
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    setState(() => _isLoadingRoute = true);
                    final waypoints = pins.map((pin) => pin.latLng).toList();
                    final route = await _routingService.getRoute(waypoints);
                    setState(() {
                      _routePoints = route;
                      _isLoadingRoute = false;
                    });
                  },
                  icon: _isLoadingRoute ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.directions_car),
                  label: const Text('Rotayı Çiz'),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                )
              : null, 
        );
      },
    );
  }
}