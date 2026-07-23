import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:travel_planner/l10n/app_localizations.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // 1. Kayıt Ol
  Future<User?> signUpWithEmail(BuildContext context, String email, String password) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = l10n.authErrorSignUp;
      if (e.code == 'weak-password') {
        errorMessage = l10n.authErrorWeakPassword;
      } else if (e.code == 'email-already-in-use') {
        errorMessage = l10n.authErrorEmailInUse;
      } else if (e.code == 'invalid-email') {
        errorMessage = l10n.authErrorInvalidEmail;
      }
      developer.log('Kayıt Hatası: ${e.code}', name: 'AuthService');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(l10n.authErrorUnexpected);
    }
  }

  // 2. Giriş Yap
  Future<User?> signInWithEmail(BuildContext context, String email, String password) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = l10n.authErrorSignIn;
      // Firebase güvenlik gereği artık "kullanıcı yok" ve "şifre yanlış" hatalarını 
      // "invalid-credential" altında birleştiriyor (Email enumeration saldırılarını önlemek için).
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = l10n.authErrorInvalidCredential;
      } else if (e.code == 'invalid-email') {
        errorMessage = l10n.authErrorInvalidEmailFormat;
      } else if (e.code == 'user-disabled') {
        errorMessage = l10n.authErrorUserDisabled;
      }
      developer.log('Giriş Hatası: ${e.code}', name: 'AuthService');
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(l10n.authErrorUnexpected);
    }
  }

  // 3. E-posta Doğrulama Linki Gönder
  Future<void> sendEmailVerification(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      developer.log('Doğrulama E-postası Hatası: $e', name: 'AuthService');
      throw Exception(l10n.authErrorVerificationEmail);
    }
  }

  // 4. Şifremi Unuttum (Sıfırlama Linki Gönder)
  Future<void> sendPasswordResetEmail(BuildContext context, String email) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = l10n.authErrorPasswordReset;
      if (e.code == 'invalid-email') {
        errorMessage = l10n.authErrorInvalidEmailReset;
      }
      throw Exception(errorMessage);
    }
  }

  // 5. Çıkış Yap
  Future<void> signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Çıkış Hatası: $e', name: 'AuthService');
      throw Exception(l10n.authErrorSignOut);
    }
  }
}