import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'features/auth/login_screen.dart';
import 'features/map/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TravelPlannerApp());
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seyahat Planlayıcı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // 1. Kullanıcı giriş yapmış mı?
          if (snapshot.hasData) {
            
            // 2. KRİTİK KONTROL: E-postası doğrulanmış mı?
            if (!snapshot.data!.emailVerified) {
              // Doğrulanmamışsa haritaya ALMA, bu uyarı ekranında tut!
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Güvenlik Onayı'),
                  centerTitle: true,
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mark_email_unread, size: 80, color: Colors.orange),
                        const SizedBox(height: 24),
                        Text(
                          'Kayıt oldunuz ancak ${snapshot.data!.email} adresini henüz onaylamadınız.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Lütfen gelen kutunuzu (veya spam klasörünü) kontrol edip onay linkine tıklayın. Onayladıktan sonra tekrar giriş yapabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Çıkış yaptırıp giriş ekranına geri yolluyoruz
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Giriş Ekranına Dön'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            
            // Eğer hem giriş yapmış hem de e-postası doğrulanmışsa Haritaya geçebilir.
            return const MapScreen();
          }
          
          // Hiç giriş yapmamışsa Login ekranı
          return const LoginScreen();
        },
      ),
    );
  }
}