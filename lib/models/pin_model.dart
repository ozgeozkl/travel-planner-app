import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class PinModel {
  final String? id;          // Firestore belge (document) ID'si
  final String userId;       // Pini ekleyen kullanıcının ID'si (Güvenlik için)
  final String title;        // Mekan adı
  final double latitude;     // Enlem
  final double longitude;    // Boylam
  final DateTime createdAt;  // Eklenme tarihi

  PinModel({
    this.id,
    required this.userId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  // 1. Yazma İşlemi (Dart -> Firebase)
  // Objemizi Firebase'in anlayacağı JSON (Map) formatına çeviririz.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore'un özel tarih formatı
    };
  }

  // 2. Okuma İşlemi (Firebase -> Dart)
  // Firebase'den gelen karmaşık veriyi alıp bizim PinModel objemize dönüştürür.
  factory PinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PinModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      // Firebase ondalıklı sayıları bazen int bazen double döndürebilir, 
      // çökmeyi önlemek için num üzerinden double'a çeviriyoruz.
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Haritada kullanmak için hızlıca LatLng objesi döndüren küçük bir yardımcı
  LatLng get latLng => LatLng(latitude, longitude);
}