import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'features/auth/login_screen.dart';
import 'features/map/map_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:travel_planner/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TravelPlannerApp());
}

class TravelPlannerApp extends StatefulWidget {
  const TravelPlannerApp({super.key});

  // Bu statik metot sayesinde uygulamanın herhangi bir yerinden 
  // (örneğin SettingsScreen'den) dili anında değiştirebileceğiz!
  static void setLocale(BuildContext context, Locale newLocale) {
    _TravelPlannerAppState? state = context.findAncestorStateOfType<_TravelPlannerAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<TravelPlannerApp> createState() => _TravelPlannerAppState();
}

class _TravelPlannerAppState extends State<TravelPlannerApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title yerine onGenerateTitle kullanıyoruz ki uygulama adı da dile göre değişsin
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      // === DİL AYARLARI ===
      locale: _locale, // Dinamik dil değişkenimiz
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
      ],
      // =====================

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
              
              // Localizations'ı home içindeki context'ten çekiyoruz
              final l10n = AppLocalizations.of(context)!;
              
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.securityApprovalTitle),
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
                          // Dinamik e-posta yerleşimi
                          l10n.emailNotVerifiedMessage(snapshot.data!.email ?? ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.checkInboxMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.returnToLoginButton),
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