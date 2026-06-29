import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Doğrulaması'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Bu kritik işlem için mevcut şifrenizi girmeniz gerekmektedir.'),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'E-posta', border: OutlineInputBorder()),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                  labelText: 'Mevcut Şifre', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
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
                if (context.mounted) {
                  Navigator.pop(context);
                  onAuthenticated();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Hatalı şifre girdiniz.'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Doğrula'),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
              labelText: 'Yeni Şifre', border: OutlineInputBorder()),
          obscureText: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (_passwordController.text.trim().length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Şifre en az 6 karakter olmalıdır.')),
                );
                return;
              }
              Navigator.pop(context);
              await _showReAuthDialog(() async {
                try {
                  await _auth.currentUser
                      ?.updatePassword(_passwordController.text.trim());
                  _passwordController.clear();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Şifreniz başarıyla güncellendi.'),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Şifre güncellenemedi.'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              });
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _handleChangeEmail() {
    final TextEditingController newEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('E-posta Değiştir'),
        content: TextField(
          controller: newEmailController,
          decoration: const InputDecoration(
              labelText: 'Yeni E-posta Adresi', border: OutlineInputBorder()),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              final newEmail = newEmailController.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Lütfen geçerli bir e-posta adresi girin.')),
                );
                return;
              }

              Navigator.pop(context);

              await _showReAuthDialog(() async {
                try {
                  await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Doğrulama Gönderildi 📩'),
                        content: const Text(
                          'Yeni e-posta adresinize bir onay bağlantısı gönderdik.\n\n'
                          'Lütfen gelen kutunuzu kontrol edin ve bağlantıya tıklayın. '
                          'Onaylama işlemini yapana kadar mevcut e-postanız görünmeye devam edecektir.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Anladım'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'E-posta güncellenemedi. Başka bir hesap tarafından kullanılıyor olabilir.'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              });
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Kalıcı Olarak Sil'),
        content: const Text(
            'Hesabınızı sildiğinizde tüm kaydedilen yerleriniz ve anılarınız kalıcı olarak silinecektir. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await _showReAuthDialog(() async {
                try {
                  await _auth.currentUser?.delete();
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Hesap silme işlemi başarısız oldu.'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              });
            },
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ayarlar',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.orange),
                  title: const Text('E-posta Değiştir'),
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
                  title: const Text('Şifre Değiştir'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleChangePassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Hesabı Kalıcı Olarak Sil'),
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