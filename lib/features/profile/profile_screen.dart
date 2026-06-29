import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/pin_model.dart';
import 'gallery_screen.dart';
import 'saved_list_screen.dart';
import '../settings/settings_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _handleChangeProfilePhoto() async {
    // image_picker paketi gereklidir: flutter pub add image_picker
    // Aşağıdaki import'u dosyanın başına ekle:
    // import 'package:image_picker/image_picker.dart';
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );
    if (pickedFile == null) return;

    try {
      // Fotoğrafı Storage'a yükle ve URL'yi Auth profiline kaydet.
      // Bu kısım DatabaseService veya StorageService'inize göre uyarlanmalıdır.
      // Örnek:
      // final url = await _databaseService.uploadProfilePhoto(pickedFile.path);
      // await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
      await _refreshUserProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil fotoğrafı güncellendi.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Fotoğraf yüklenemedi.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshUserProfile() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profilim',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<PinModel>>(
        stream: _databaseService.getUserPins(),
        builder: (context, snapshot) {
          final pins = snapshot.data ?? [];
          final photoPins = pins.where((p) => p.imageUrl != null).toList();

          return RefreshIndicator(
            onRefresh: _refreshUserProfile,
            color: Colors.blue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profil Başlığı
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: _currentUser?.photoURL != null
                                  ? NetworkImage(_currentUser!.photoURL!)
                                  : null,
                              child: _currentUser?.photoURL == null
                                  ? Text(
                                      (_currentUser?.email?.isNotEmpty == true)
                                          ? _currentUser!.email![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _handleChangeProfilePhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentUser?.email ?? '',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // İstatistik Kartları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final selectedLocation = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SavedListScreen(pins: pins),
                                ),
                              );
                              if (selectedLocation != null &&
                                  context.mounted) {
                                Navigator.pop(context, selectedLocation);
                              }
                            },
                            child: _buildStatCard('Kayıtlı Yer',
                                pins.length.toString(), Icons.map, Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GalleryScreen(photos: photoPins),
                              ),
                            ),
                            child: _buildStatCard(
                                'Fotoğraflar',
                                photoPins.length.toString(),
                                Icons.photo_library,
                                Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menü
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        _buildMenuTile(
                            Icons.calendar_month, 'Seyahat Planlama', () {},
                            iconColor: Colors.orange),
                        const Divider(height: 1),
                        _buildMenuTile(Icons.settings, 'Ayarlar', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                        }, iconColor: Colors.blueGrey),
                        const Divider(height: 1),
                        _buildMenuTile(
                            Icons.logout, 'Çıkış Yap', () => _authService.signOut(),
                            iconColor: Colors.red),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.grey}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}