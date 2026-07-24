import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/l10n/app_localizations.dart';
// AppLocalizations importunu kendi projene göre eklediğinden emin ol
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class GeneralNotesScreen extends StatefulWidget {
  const GeneralNotesScreen({super.key});

  @override
  State<GeneralNotesScreen> createState() => _GeneralNotesScreenState();
}

class _GeneralNotesScreenState extends State<GeneralNotesScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Sayfa açıldığında kayıtlı notları getir
  }

  // SharedPreferences'tan notları okuma
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notesController.text = prefs.getString('general_notes_key') ?? '';
    });
  }

  // SharedPreferences'a notları kaydetme
  Future<void> _saveNotes(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('general_notes_key', value);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Çevirileri pratik kullanmak için bir değişkene atıyoruz
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Sabit 'Genel Notlar' yerine dil dosyasından çekiyoruz
        title: Text(localizations.generalNotesTitle), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null, 
                expands: true, 
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  // Sabit hintText yerine dil dosyasından çekiyoruz
                  hintText: localizations.generalNotesHint,
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _saveNotes(value); 
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}