import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import '../models/pin_model.dart';
import '../models/trip_model.dart';


class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. KULLANICININ PİNLERİNİ GETİRME
  Stream<List<PinModel>> getUserPins() {
    return _db
        .collection('pins')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PinModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 2. YENİ PİN EKLEME
  Future<void> addPin(PinModel pin) async {
    try {
      await _db.collection('pins').add(pin.toMap());
      developer.log('Pin başarıyla eklendi', name: 'DatabaseService');
    } catch (e) {
      developer.log('Add error: $e', name: 'DatabaseService');
      throw Exception('Yer kaydedilemedi.');
    }
  }

  // 3. PİN GÜNCELLEME (Hata Aldığın Eksik Fonksiyon)
  Future<void> updatePin(PinModel pin) async {
    try {
      if (pin.id != null) {
        await _db.collection('pins').doc(pin.id).update(pin.toMap());
        developer.log('Pin başarıyla güncellendi', name: 'DatabaseService');
      } else {
        throw Exception('Güncellenecek pinin IDsi bulunamadı.');
      }
    } catch (e) {
      developer.log('Pin güncellenirken hata: $e', name: 'DatabaseService');
      throw Exception('Yer güncellenemedi.');
    }
  }

  // 4. PİN VE FOTOĞRAF SİLME
  Future<void> deletePin(String id) async {
    try {
      final doc = await _db.collection('pins').doc(id).get();
      if (doc.exists) {
        final pin = PinModel.fromMap(doc.data()!, doc.id);
        
        // Eğer pinin içinde fotoğraf URL'si varsa, Firebase Storage'dan da o dosyayı sil
        if (pin.imageUrl != null && pin.imageUrl!.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(pin.imageUrl!);
            await ref.delete();
            developer.log('Pinin fotoğrafı Storage\'dan silindi.', name: 'DatabaseService');
          } catch (storageError) {
            developer.log('Storage silme hatası: $storageError', name: 'DatabaseService');
          }
        }
      }

      // Veritabanından sil
      await _db.collection('pins').doc(id).delete();
      developer.log('Pin başarıyla silindi', name: 'DatabaseService');
    } catch (e) {
      developer.log('Pin silinirken hata: $e', name: 'DatabaseService');
      throw Exception('Yer silinemedi.');
    }
  }
  Future<void> addTrip(TripModel trip) async {
    await _db.collection('trips').add(trip.toMap());
  }

Stream<List<TripModel>> getUserTrips() {
    return _db
        .collection('trips')
        // BURASI DÜZELTİLDİ: _auth yerine FirebaseAuth.instance kullanıyoruz
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TripModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTrip(TripModel trip) async {
    if (trip.id != null) {
      await _db.collection('trips').doc(trip.id).update(trip.toMap());
    }
  }

  Future<void> deleteTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).delete();
  }
}