import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:travel_planner/l10n/app_localizations.dart';
import 'package:travel_planner/main.dart'; // Dil değiştirmek için TravelPlannerApp'i import ettik

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // 1. Boş alan kontrolü
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerEmptyFieldsError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase Auth ile kullanıcıyı kaydet
      await _authService.signUpWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // 3. Gerçek e-posta doğrulama linkini gönder
      await _authService.sendEmailVerification(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccessMsg),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        // Kayıt işleminden sonra giriş ekranına geri dön
        Navigator.pop(context);
      }
    } catch (e) {
      // 4. Hata yakalama (Zayıf şifre veya alınmış e-posta hataları)
      if (mounted) {
        final cleanMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cleanMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // L10n değişkenini tanımlıyoruz
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerAppBarTitle),
        // SAĞ ÜST KÖŞE - DİL SEÇİMİ BUTONU (AppBar Actions içine eklendi)
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Dil Seç / Language',
            onSelected: (String languageCode) {
              TravelPlannerApp.setLocale(context, Locale(languageCode));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'tr',
                child: Text('🇹🇷 Türkçe'),
              ),
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('🇬🇧 English'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // İkon
                const Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                
                // Açıklama
                Text(
                  l10n.registerTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                // E-posta Girişi
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.registerEmailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre Girişi
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.registerPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Kayıt Ol Butonu
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.registerButton,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}