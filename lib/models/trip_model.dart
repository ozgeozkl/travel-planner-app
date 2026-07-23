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
  final Map<String, dynamic> lockedPins; 
  final bool isArchived; // YENİ: Manuel arşivlenme durumu

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
    this.lockedPins = const {},
    this.isArchived = false, // Varsayılan: Arşivlenmemiş
  });

  // YENİ Yardımcı Getter: Bitiş tarihi geçti mi veya manuel arşivlendi mi?
  bool get isPast {
    if (isArchived) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return tripEnd.isBefore(today);
  }

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
      'lockedPins': lockedPins,
      'isArchived': isArchived,
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
      lockedPins: map['lockedPins'] as Map<String, dynamic>? ?? {},
      isArchived: map['isArchived'] ?? false,
    );
  }
}