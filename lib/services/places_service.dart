import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Çekilen mekanları tutacağımız basit bir model
class PlaceResult {
  final String name;
  final String type; // cafe, restaurant, museum vs.
  final LatLng location;

  PlaceResult({required this.name, required this.type, required this.location});
}

class PlacesService {
  // Verilen merkezin 1000 metre (1km) etrafındaki mekanları getirir
  Future<List<PlaceResult>> getNearbyPlaces(LatLng center, {int radius = 1000}) async {
    // Overpass QL Sorgusu: Turistik yerler, kafeler ve restoranları istiyoruz
    final String query = '''
      [out:json];
      (
        node["tourism"](around:$radius,${center.latitude},${center.longitude});
        node["amenity"="restaurant"](around:$radius,${center.latitude},${center.longitude});
        node["amenity"="cafe"](around:$radius,${center.latitude},${center.longitude});
      );
      out body;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      final response = await http.post(url, body: query);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<PlaceResult> results = [];
        
        for (var el in elements) {
          // Sadece ismi olan mekanları listeye al
          if (el['tags'] != null && el['tags']['name'] != null) {
            final name = el['tags']['name'];
            final type = el['tags']['tourism'] ?? el['tags']['amenity'] ?? 'Mekan';
            final lat = el['lat'] as double;
            final lon = el['lon'] as double;
            
            results.add(PlaceResult(name: name, type: type, location: LatLng(lat, lon)));
          }
        }
        return results;
      }
    } catch (e) {
      developer.log('Places API Hatası: $e', name: 'PlacesService');
    }
    return [];
  }
}