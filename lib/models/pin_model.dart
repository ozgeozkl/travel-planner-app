import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class PinModel {
  final String? id;
  final String userId;
  final String title;
  final String? note;       // YENİ: İsteğe bağlı not alanı
  final int color;          // YENİ: Renk kodu (Sayısal değer olarak)
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  PinModel({
    this.id,
    required this.userId,
    required this.title,
    this.note,
    required this.color,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'note': note,
      'color': color,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PinModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      note: map['note'], // Null olabilir
      // Renk yoksa varsayılan olarak Kırmızı (0xFFF44336) yap
      color: map['color'] ?? 0xFFF44336, 
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}