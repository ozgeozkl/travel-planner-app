import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 1. Kayıt Ol
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Kayıt olurken bir hata oluştu.';
      if (e.code == 'weak-password') {
        errorMessage = 'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre belirleyin.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi ile zaten kayıtlı bir hesap bulunuyor.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
      }
      developer.log('Kayıt Hatası: ${e.code}', name: 'AuthService');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu.');
    }
  }

  // 2. Giriş Yap
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş yapılamadı.';
      // Firebase güvenlik gereği artık "kullanıcı yok" ve "şifre yanlış" hatalarını 
      // "invalid-credential" altında birleştiriyor (Email enumeration saldırılarını önlemek için).
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'E-posta adresiniz veya şifreniz hatalı. Lütfen kontrol edin.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Lütfen geçerli bir e-posta adresi formatı girin.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Bu kullanıcı hesabı sistem tarafından engellenmiş.';
      }
      developer.log('Giriş Hatası: ${e.code}', name: 'AuthService');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu.');
    }
  }

  // 3. E-posta Doğrulama Linki Gönder
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      developer.log('Doğrulama E-postası Hatası: $e', name: 'AuthService');
      throw Exception('Doğrulama e-postası gönderilemedi.');
    }
  }

  // 4. Şifremi Unuttum (Sıfırlama Linki Gönder)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Şifre sıfırlama linki gönderilemedi.';
      if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz bir e-posta adresi girdiniz.';
      }
      throw Exception(errorMessage);
    }
  }

  // 5. Çıkış Yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Çıkış Hatası: $e', name: 'AuthService');
      throw Exception('Çıkış yapılırken bir sorun oluştu.');
    }
  }
}