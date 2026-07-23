import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'package:travel_planner/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _showReAuthDialog(Function onAuthenticated) async {
    final TextEditingController emailController =
        TextEditingController(text: _auth.currentUser?.email);
    final TextEditingController currentPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.settingsSecurityAuthTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settingsSecurityAuthSubtitle),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: l10n.settingsEmailLabel, border: const OutlineInputBorder()),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                    labelText: l10n.settingsCurrentPasswordLabel, border: const OutlineInputBorder()),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.settingsCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: emailController.text.trim(),
                    password: currentPasswordController.text.trim(),
                  );
                  await _auth.currentUser
                      ?.reauthenticateWithCredential(credential);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    onAuthenticated();
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                          content: Text(l10n.settingsWrongPassword),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(l10n.settingsVerify),
            ),
          ],
        );
      },
    );
  }

  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.settingsChangePasswordTitle),
          content: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
                labelText: l10n.settingsNewPasswordLabel, border: const OutlineInputBorder()),
            obscureText: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.settingsCancel)),
            ElevatedButton(
              onPressed: () async {
                if (_passwordController.text.trim().length < 6) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                        content: Text(l10n.settingsPasswordLengthError)),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                await _showReAuthDialog(() async {
                  try {
                    await _auth.currentUser
                        ?.updatePassword(_passwordController.text.trim());
                    _passwordController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsPasswordUpdateSuccess),
                            backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsPasswordUpdateError),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                });
              },
              child: Text(l10n.settingsUpdate),
            ),
          ],
        );
      },
    );
  }

  void _handleChangeEmail() {
    final TextEditingController newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.settingsChangeEmailTitle),
          content: TextField(
            controller: newEmailController,
            decoration: InputDecoration(
                labelText: l10n.settingsNewEmailLabel, border: const OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.settingsCancel)),
            ElevatedButton(
              onPressed: () async {
                final newEmail = newEmailController.text.trim();
                if (newEmail.isEmpty || !newEmail.contains('@')) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                        content:
                            Text(l10n.settingsInvalidEmailError)),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                await _showReAuthDialog(() async {
                  try {
                    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);

                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (innerDialogContext) {
                          final innerL10n = AppLocalizations.of(innerDialogContext)!;
                          return AlertDialog(
                            title: Text(innerL10n.settingsVerificationSentTitle),
                            content: Text(innerL10n.settingsVerificationSentBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(innerDialogContext),
                                child: Text(innerL10n.settingsGotIt),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsEmailUpdateError),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                });
              },
              child: Text(l10n.settingsUpdate),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.settingsDeleteAccountTitle),
          content: Text(l10n.settingsDeleteAccountWarning),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.settingsCancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _showReAuthDialog(() async {
                  try {
                    await _auth.currentUser?.delete();
                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(AppLocalizations.of(context)!.settingsDeleteAccountError),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                });
              },
              child: Text(l10n.settingsDeleteAccountConfirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Sistemdeki anlık dili çekiyoruz (tr veya en)
    final currentLanguageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.settingsAppBarTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                // DİL SEÇİM MENÜSÜ EKLENDİ
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.green),
                  title: Text(l10n.settingsAppLanguage),
                  trailing: DropdownButton<String>(
                    value: currentLanguageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (String? newLanguageCode) {
                      if (newLanguageCode != null && newLanguageCode != currentLanguageCode) {
                        // TODO: Main.dart içerisindeki locale durumunu güncelleyen fonksiyonu çağır.
                        // Örnek: Eğer main.dart'ta Provider veya Riverpod kullanıyorsan burada tetiklemen gerekir.
                        // Veya GlobalKey kullanıyorsan: MyApp.setLocale(context, Locale(newLanguageCode));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.orange),
                  title: Text(l10n.settingsChangeEmailTitle),
                  subtitle: Text(
                    _auth.currentUser?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleChangeEmail,
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.lock_reset, color: Colors.blue),
                  title: Text(l10n.settingsChangePasswordTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleChangePassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(l10n.settingsDeleteAccountTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}