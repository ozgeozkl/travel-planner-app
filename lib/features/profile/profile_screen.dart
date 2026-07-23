import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/pin_model.dart';
import 'gallery_screen.dart';
import 'saved_list_screen.dart';
import '../planner/planner_screen.dart';
import 'package:travel_planner/l10n/app_localizations.dart';
import '../settings/settings_screen.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );
    if (pickedFile == null) return;

    try {
      final bytes = await pickedFile.readAsBytes();
      final String fileName = 'profiles/${_currentUser!.uid}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final String downloadUrl = await ref.getDownloadURL();
      
      await _currentUser!.updatePhotoURL(downloadUrl);

      await _refreshUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.profilePhotoUpdated),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.profilePhotoUploadFailed),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.profileAppBarTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            child: _buildStatCard(l10n.profileStatSavedPlaces,
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
                                l10n.profileStatPhotos,
                                photoPins.length.toString(),
                                Icons.photo_library,
                                Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        _buildMenuTile(Icons.calendar_month, l10n.profileMenuTripPlanner, () async {
                          final resultPin = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlannerScreen()),
                          );
                          
                          if (resultPin != null && context.mounted) {
                            Navigator.pop(context, resultPin);
                          }
                        }, iconColor: Colors.orange), 
                        
                        _buildMenuTile(Icons.history, l10n.profileMenuPastTrips, () async {
                          final resultPin = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlannerScreen(initialTabIndex: 1), 
                            ),
                          );

                          if (resultPin != null && context.mounted) {
                            Navigator.pop(context, resultPin);
                          }
                        }, iconColor: Colors.blueGrey),

                        const Divider(height: 1),
                        
                        // YENİ EKLENEN AYARLAR BUTONU BURADA
                        _buildMenuTile(
                          Icons.settings, 
                          l10n.settingsAppBarTitle, 
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          iconColor: Colors.grey
                        ),

                        const Divider(height: 1),
                        
                        _buildMenuTile(
                            Icons.logout, l10n.profileMenuLogout, () => _authService.signOut(context),
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