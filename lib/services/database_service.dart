import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../models/pin_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Yeni Pin Ekle (Create)
  Future<void> addPin(PinModel pin) async {
    try {
      // Firestore'da 'pins' adında bir koleksiyon oluşturup veriyi içine atıyoruz
      await _db.collection('pins').add(pin.toMap());
      developer.log('Pin başarıyla eklendi', name: 'DatabaseService');
    } catch (e) {
      developer.log('Pin eklenirken hata: $e', name: 'DatabaseService');
      throw Exception('Yer kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  // 2. Kullanıcının Pinlerini Dinle (Read - Stream)
  // Stream yapısı kullanıyoruz. Bu sayede veritabanına yeni bir pin eklendiğinde,
  // silindiğinde veya güncellendiğinde harita ekranı anında (sayfayı yenilemeden) tepki verir.
  Stream<List<PinModel>> getUserPins() {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      // Kullanıcı giriş yapmamışsa boş bir akış döndür
      return Stream.value([]); 
    }

    // Sadece giriş yapan kullanıcının kendi pinlerini getir (Güvenlik Kuralı)
    return _db
        .collection('pins')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Firestore'dan gelen verileri (QuerySnapshot), bizim oluşturduğumuz PinModel listesine çeviriyoruz
      return snapshot.docs.map((doc) {
        return PinModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 3. Pin Silme (İleride kullanmak için altyapıyı şimdiden atalım)
  Future<void> deletePin(String pinId) async {
    try {
      await _db.collection('pins').doc(pinId).delete();
    } catch (e) {
      developer.log('Pin silinirken hata: $e', name: 'DatabaseService');
      throw Exception('Yer silinemedi.');
    }
  }
}