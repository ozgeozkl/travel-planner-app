import 'package:flutter/material.dart';
import '../../models/pin_model.dart';

class SavedListScreen extends StatelessWidget {
  final List<PinModel> pins;
  const SavedListScreen({super.key, required this.pins});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaydedilen Yerler', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: pins.isEmpty
          ? const Center(child: Text('Henüz kaydedilmiş bir yer yok.'))
          : ListView.separated(
              itemCount: pins.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                final pin = pins[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(pin.color).withOpacity(0.15),
                    child: Icon(Icons.location_on, color: Color(pin.color), size: 28),
                  ),
                  title: Text(
                    pin.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eğer kullanıcının özel bir notu varsa göster
                        if (pin.note != null && pin.note!.isNotEmpty) ...[
                          Text(pin.note!, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                          const SizedBox(height: 8),
                        ],
                        // YENİ: Bulunan gerçek adresi şık bir ikonla gösteriyoruz
                        Row(
                          children: [
                            const Icon(Icons.place, size: 16, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                pin.address ?? 'Adres bilgisi bulunamadı', // Adres burada görünecek
                                style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
              Navigator.pop(context, pin.latLng);
                  },
                );
              },
            ),
    );
  }
}