import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // EKLENDİ
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

  static void setLocale(BuildContext context, Locale newLocale) {
    _TravelPlannerAppState? state = context.findAncestorStateOfType<_TravelPlannerAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<TravelPlannerApp> createState() => _TravelPlannerAppState();
}

class _TravelPlannerAppState extends State<TravelPlannerApp> {
  Locale? _locale;

  // EKLENDİ: Uygulama başlarken hafızadaki dili yükle
  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('languageCode');
    
    if (savedLanguage != null) {
      setState(() {
        _locale = Locale(savedLanguage);
      });
    }
  }

  // GÜNCELLENDİ: Dil değiştiğinde hem arayüzü güncelle hem de hafızaya kaydet
  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      // === DİL AYARLARI ===
      locale: _locale, 
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), 
        Locale('en'), 
      ],
      // =====================

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasData) {
            if (!snapshot.data!.emailVerified) {
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
            return const MapScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}