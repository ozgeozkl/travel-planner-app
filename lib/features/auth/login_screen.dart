import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart'; 
import '../map/map_screen.dart';
import 'package:travel_planner/l10n/app_localizations.dart';
import 'package:travel_planner/main.dart'; // Dil değiştirmek için TravelPlannerApp'i import ettik

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // 1. Boş alan kontrolü
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emptyFieldsError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Giriş isteği
      final user = await _authService.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // 3. E-POSTA DOĞRULAMA KONTROLÜ
      if (user != null && !user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.emailVerifyError),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        await _authService.signOut(context);
        return; 
      }

      // 4. Başarılı giriş
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loginSuccess),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
      }
    } catch (e) {
      // 5. Hata yakalama
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Ana form içeriğimiz ortalanmış şekilde kalmaya devam ediyor
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Icon(
                      Icons.map_outlined,
                      size: 100,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 32),
                    
                    // Başlıklar
                    Text(
                      'Travel Planner', // Proje adı olduğu için sabit bırakıldı
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // E-posta Alanı
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel, // Dinamik metin
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Şifre Alanı
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel, // Dinamik metin
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    
                    // Şifremi Unuttum Butonu
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          if (_emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.emailRequiredForReset),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          
                          try {
                            await _authService.sendPasswordResetEmail(context, _emailController.text.trim());
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.passwordResetSent),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              final cleanMessage = e.toString().replaceAll('Exception: ', '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(cleanMessage),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(l10n.forgotPassword), // Dinamik metin
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Giriş Yap Butonu
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                l10n.loginButton, // Dinamik metin
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kayıt Ol Yönlendirmesi
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(l10n.noAccountRegister), // Dinamik metin
                    ),
                  ],
                ),
              ),
            ),

            // SAĞ ÜST KÖŞE - DİL SEÇİMİ BUTONU
            Positioned(
              top: 16,
              right: 16,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.language, color: Colors.grey, size: 28),
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
            ),
          ],
        ),
      ),
    );
  }
}