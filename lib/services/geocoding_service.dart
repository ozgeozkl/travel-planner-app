import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // Arama metnini (Örn: "Galata Kulesi") alıp koordinata çeviren fonksiyon
  Future<LatLng?> searchPlace(String query) async {
    // Nominatim API URL'i (limit=1 diyerek sadece en alakalı ilk sonucu istiyoruz)
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
    
    try {
      final response = await http.get(url, headers: {
        // OSM sunucularının bizi engellememesi için User-Agent veriyoruz
        'User-Agent': 'com.example.travel_planner',
      });
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        
        // Eğer sonuç boş dönmediyse (mekan bulunduysa)
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon); // Koordinatı döndür
        }
      }
    } catch (e) {
      developer.log('Arama işlemi sırasında hata oluştu: $e', name: 'GeocodingService');
    }
    
    // Bulunamazsa veya hata olursa null döndür
    return null;
  }
}