import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes; 
  final List<String> selectedPinIds; 
  final Map<String, dynamic> itinerary; 
  final int themeColor;
  
  // YENİ EKLENEN: Hangi pinin hangi güne sabitlendiğini tutar
  // Örnek: {'pinId_1': '2'} -> pinId_1 isimli mekan 2. güne sabitlenmiş demektir.
  final Map<String, dynamic> lockedPins; 

  TripModel({
    this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.selectedPinIds = const [], 
    this.itinerary = const {},
    this.themeColor = 0xFFFF5722,
    this.lockedPins = const {}, // Varsayılan olarak boş sabitleme matrisi
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
      'selectedPinIds': selectedPinIds,
      'itinerary': itinerary,
      'themeColor': themeColor,
      'lockedPins': lockedPins, // Veritabanına kaydet
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TripModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      notes: map['notes'],
      selectedPinIds: List<String>.from(map['selectedPinIds'] ?? []),
      itinerary: map['itinerary'] as Map<String, dynamic>? ?? {},
      themeColor: map['themeColor'] ?? 0xFFFF5722,
      lockedPins: map['lockedPins'] as Map<String, dynamic>? ?? {}, // Veritabanından oku
    );
  }
}