import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class PinModel {
  final String? id;
  final String userId;
  final String title;
  final String? note;
  final int color;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? imageUrl; // YENİ: Fotoğraf URL'si

  PinModel({
    this.id,
    required this.userId,
    required this.title,
    this.note,
    required this.color,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.imageUrl, // YENİ
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
      'imageUrl': imageUrl, // YENİ
    };
  }

  factory PinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PinModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      note: map['note'],
      color: map['color'] ?? 0xFFF44336,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'], // YENİ
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}