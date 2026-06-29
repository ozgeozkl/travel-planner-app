import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; // Harita sınırları (LatLngBounds) için eklendi

class SearchResult {
  final String name;
  final LatLng location;

  SearchResult({required this.name, required this.location});
}

class GeocodingService {
  // YENİ: Hem biasLocation (Merkez) hem de bounds (Ekran Çerçevesi) alabilir
  Future<List<SearchResult>> searchPlace(String query, {LatLng? biasLocation, LatLngBounds? bounds}) async {
    
    String urlString = 'https://photon.komoot.io/api/?q=$query&limit=5';
    
    // Eğer ekranın çerçevesi verildiyse (En Kesin Arama)
    if (bounds != null) {
      // Photon Formatı: minLon, minLat, maxLon, maxLat (Batı, Güney, Doğu, Kuzey)
      urlString += '&bbox=${bounds.west},${bounds.south},${bounds.east},${bounds.north}';
    } 
    // Eğer çerçeve yok ama merkez nokta verildiyse (Yumuşak Arama)
    else if (biasLocation != null) {
      urlString += '&lat=${biasLocation.latitude}&lon=${biasLocation.longitude}';
    }

    final url = Uri.parse(urlString);
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        List<SearchResult> results = [];
        
        for (var f in features) {
          final coords = f['geometry']['coordinates']; 
          final props = f['properties'];
          
          final name = props['name'] ?? props['street'] ?? query; 
          
          results.add(SearchResult(
            name: name,
            location: LatLng(coords[1], coords[0]), 
          ));
        }
        return results;
      }
    } catch (e) {
      developer.log('Arama Hatası: $e', name: 'GeocodingService');
    }
    return [];
  }
  // YENİ: Koordinattan adres üreten fonksiyon
  Future<String?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse('https://photon.komoot.io/reverse?lon=$lon&lat=$lat');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final properties = data['features'][0]['properties'];
          
          // Bulunan en mantıklı konum parçalarını birleştiriyoruz
          String name = properties['name'] ?? '';
          String district = properties['district'] ?? properties['city'] ?? '';
          String state = properties['state'] ?? '';
          
          List<String> parts = [];
          if (name.isNotEmpty) parts.add(name);
          if (district.isNotEmpty && district != name) parts.add(district);
          if (state.isNotEmpty && state != district) parts.add(state);
          
          if (parts.isNotEmpty) {
            return parts.join(', '); // Örn: "Caferağa, İstanbul"
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}