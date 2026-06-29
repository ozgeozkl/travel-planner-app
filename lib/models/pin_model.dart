import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class PinModel {
  String? id;
  final String userId;
  final String title;
  final String? note;
  final int color;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? imageUrl;
  final String? address; // YENİ: Adres alanı eklendi

  PinModel({
    this.id,
    required this.userId,
    required this.title,
    this.note,
    required this.color,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.imageUrl,
    this.address,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'note': note,
      'color': color,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'address': address, // YENİ
    };
  }

  factory PinModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PinModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      note: map['note'],
      color: map['color'] ?? 0xFFF44336,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      address: map['address'], // YENİ
    );
  }
}