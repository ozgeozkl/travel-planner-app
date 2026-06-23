import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  final String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> getRoute(List<LatLng> waypoints) async {
    // Rota çizmek için en az 2 nokta olmalı
    if (waypoints.length < 2) return [];

    // OSRM API'si koordinatları "boylam,enlem;boylam,enlem" formatında bekler
    final String coordinates = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');

    final String url = '$_baseUrl/$coordinates?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List geometryCoordinates = data['routes'][0]['geometry']['coordinates'];

        // Gelen [boylam, enlem] verisini FlutterMap için [enlem, boylam] formatına çeviriyoruz
        return geometryCoordinates.map((coord) {
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();
      } else {
        developer.log('Rota API Hatası: ${response.statusCode}', name: 'RoutingService');
        return [];
      }
    } catch (e) {
      developer.log('Rota çekilirken hata oluştu: $e', name: 'RoutingService');
      return [];
    }
  }
}