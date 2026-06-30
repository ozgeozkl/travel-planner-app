import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/trip_model.dart';
import '../../models/pin_model.dart';
import '../../services/database_service.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel trip;
  
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late TextEditingController _notesController;
  late List<String> _selectedPinIds;
  late Map<String, dynamic> _itinerary;
  late Map<String, dynamic> _lockedPins; // Sabitlenmiş pinler haritası
  late int _themeColor;
  int _activeDayIndex = 1;

  final List<Color> _availableColors = [
    Colors.deepOrange,
    Colors.teal,
    Colors.indigo,
    Colors.purple,
    Colors.green,
    Colors.blueAccent,
    Colors.pink,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.trip.notes);
    _selectedPinIds = List.from(widget.trip.selectedPinIds);
    _itinerary = Map.from(widget.trip.itinerary);
    _lockedPins = Map.from(widget.trip.lockedPins);
    _themeColor = widget.trip.themeColor; 
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateFirebase() {
    final updatedTrip = TripModel(
      id: widget.trip.id,
      userId: widget.trip.userId,
      title: widget.trip.title,
      startDate: widget.trip.startDate,
      endDate: widget.trip.endDate,
      notes: _notesController.text.trim(),
      selectedPinIds: _selectedPinIds,
      itinerary: _itinerary,
      themeColor: _themeColor,
      lockedPins: _lockedPins,
    );
    _databaseService.updateTrip(updatedTrip);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gezi Temasını Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = _themeColor == color.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() { _themeColor = color.value; });
                        _updateFirebase();
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 60,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.black87, width: 3) : null,
                          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 30) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _togglePinSelection(String pinId) {
    setState(() {
      if (_selectedPinIds.contains(pinId)) {
        _selectedPinIds.remove(pinId);
        _lockedPins.remove(pinId); // Havuzdan çıkarsa kilidi de kalksın
        _itinerary.forEach((day, pinList) {
          if (pinList is List) pinList.remove(pinId);
        });
      } else {
        _selectedPinIds.add(pinId);
      }
    });
    _updateFirebase();
  }

  // YENİ: Pini o güne sabitleme/kilitleme fonksiyonu
  void _togglePinLock(String pinId) {
    setState(() {
      if (_lockedPins.containsKey(pinId)) {
        _lockedPins.remove(pinId); // Kilitliyse kilidi aç
      } else {
        _lockedPins[pinId] = _activeDayIndex.toString(); // Değilse aktif güne sabitle
      }
    });
    _updateFirebase();
  }

  void _addPinToDay(String pinId, int dayNumber) {
    setState(() {
      final String dayKey = dayNumber.toString();
      if (_itinerary[dayKey] == null) _itinerary[dayKey] = <String>[];
      List<String> dayPins = List<String>.from(_itinerary[dayKey]);
      if (!dayPins.contains(pinId)) {
        dayPins.add(pinId);
        _itinerary[dayKey] = dayPins;
      }
    });
    _updateFirebase();
  }

  void _removePinFromDay(String pinId, int dayNumber) {
    setState(() {
      final String dayKey = dayNumber.toString();
      _lockedPins.remove(pinId); // Günden silinirse kilidi de silinsin
      if (_itinerary[dayKey] != null) {
        List<String> dayPins = List<String>.from(_itinerary[dayKey]);
        dayPins.remove(pinId);
        _itinerary[dayKey] = dayPins;
      }
    });
    _updateFirebase();
  }

  void _onReorderPins(int oldIndex, int newIndex) {
    setState(() {
      final String dayKey = _activeDayIndex.toString();
      List<String> dayPins = List<String>.from(_itinerary[dayKey] ?? []);
      if (newIndex > oldIndex) newIndex -= 1;
      final String item = dayPins.removeAt(oldIndex);
      dayPins.insert(newIndex, item);
      _itinerary[dayKey] = dayPins;
    });
    _updateFirebase();
  }

  void _moveSinglePinToAnotherDay(String pinId, int fromDay, int toDay) {
    setState(() {
      // Başka güne taşınırsa eski kilit geçersiz olur, yeni güne güncellenir (eğer kilitliyse)
      if (_lockedPins.containsKey(pinId)) {
        _lockedPins[pinId] = toDay.toString();
      }
      
      if (_itinerary[fromDay.toString()] != null) {
        List<String> fromPins = List<String>.from(_itinerary[fromDay.toString()]);
        fromPins.remove(pinId);
        _itinerary[fromDay.toString()] = fromPins;
      }
      final String toKey = toDay.toString();
      if (_itinerary[toKey] == null) _itinerary[toKey] = <String>[];
      List<String> toPins = List<String>.from(_itinerary[toKey]);
      if (!toPins.contains(pinId)) {
        toPins.add(pinId);
        _itinerary[toKey] = toPins;
      }
    });
    _updateFirebase();
  }

  void _showBulkMoveDialog(int totalDays) {
    int targetDay = _activeDayIndex == 1 ? 2 : 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$_activeDayIndex. Günü Toplu Taşı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bu gündeki tüm mekanları hangi güne aktarmak istiyorsunuz?'),
              const SizedBox(height: 15),
              DropdownButtonFormField<int>(
                value: targetDay,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Hedef Gün'),
                items: List.generate(totalDays, (index) => index + 1)
                    .where((d) => d != _activeDayIndex)
                    .map((d) => DropdownMenuItem(value: d, child: Text('$d. Gün'))).toList(),
                onChanged: (val) { if (val != null) targetDay = val; },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(_themeColor), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  final String sourceKey = _activeDayIndex.toString();
                  final String targetKey = targetDay.toString();
                  List<String> sourcePins = List<String>.from(_itinerary[sourceKey] ?? []);
                  List<String> targetPins = List<String>.from(_itinerary[targetKey] ?? []);
                  for (var id in sourcePins) {
                    if (!targetPins.contains(id)) {
                      targetPins.add(id);
                      if (_lockedPins.containsKey(id)) _lockedPins[id] = targetKey;
                    }
                  }
                  _itinerary[targetKey] = targetPins;
                  _itinerary[sourceKey] = <String>[];
                });
                _updateFirebase();
              },
              child: const Text('Hepsini Taşı'),
            ),
          ],
        );
      },
    );
  }

  // YENİLENDİ: Sabitleme (Kısıtlama) Destekli Akıllı Dağıt Algoritması
  void _optimizeAllDaysRoute(List<PinModel> allPins, int totalDays) {
    final List<PinModel> poolPins = allPins.where((p) => _selectedPinIds.contains(p.id ?? p.title)).toList();
    if (poolPins.isEmpty) return;

    Map<String, List<String>> newItinerary = {};
    for (int i = 1; i <= totalDays; i++) {
      newItinerary[i.toString()] = [];
    }

    // 1. AŞAMA: Önce kilitli pinleri ait oldukları günlere yerleştir ve sabit tut
    _lockedPins.forEach((pinId, dayStr) {
      if (_selectedPinIds.contains(pinId) && int.parse(dayStr) <= totalDays) {
        newItinerary[dayStr.toString()]!.add(pinId);
      }
    });

    // 2. AŞAMA: Havuzdaki pinlerden "Kilitli Olmayanları" serbest dağıtılacaklar listesine al
    List<PinModel> unassigned = poolPins.where((p) {
      final id = p.id ?? p.title;
      return !_lockedPins.containsKey(id);
    }).toList();

    int currentDay = 1;
    int maxPinsPerDay = (poolPins.length / totalDays).ceil();

    while (unassigned.isNotEmpty) {
      // Eğer o gün tamamen boşsa (kilitli pini de yoksa), serbest olan ilk pini o güne çapa (seed) yap
      if (newItinerary[currentDay.toString()]!.isEmpty) {
        PinModel seed = unassigned.removeAt(0);
        newItinerary[currentDay.toString()]!.add(seed.id ?? seed.title);
      }

      if (unassigned.isEmpty) break;

      // Günün son eklenen mekanını referans alarak en yakın pini bul
      String lastPinId = newItinerary[currentDay.toString()]!.last;
      PinModel lastPin = poolPins.firstWhere((p) => (p.id ?? p.title) == lastPinId);

      double minTargetDist = double.maxFinite;
      int targetIdx = -1;

      for (int i = 0; i < unassigned.length; i++) {
        double d = _calculateDistance(lastPin.latitude, lastPin.longitude, unassigned[i].latitude, unassigned[i].longitude);
        if (d < minTargetDist) {
          minTargetDist = d;
          targetIdx = i;
        }
      }

      if (targetIdx != -1) {
        PinModel nextPin = unassigned.removeAt(targetIdx);
        newItinerary[currentDay.toString()]!.add(nextPin.id ?? nextPin.title);
      }

      // Gün dolduysa ve henüz son günde değilsek sonraki güne geç
      if (newItinerary[currentDay.toString()]!.length >= maxPinsPerDay && currentDay < totalDays) {
        currentDay++;
      } else if (currentDay == totalDays && unassigned.isNotEmpty) {
        // Son gündeysek kalan her şeyi son güne ekle
        for (var p in unassigned) {
          newItinerary[currentDay.toString()]!.add(p.id ?? p.title);
        }
        unassigned.clear();
      }
    }

    setState(() { _itinerary = newItinerary; });
    _updateFirebase();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('🔒 Sabitlenen yerler korunarak akıllı dağıtım yapıldı!'), backgroundColor: Color(_themeColor)));
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - math.cos((lat2 - lat1) * p)/2 + math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _saveNotes() {
    _updateFirebase();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notlar kaydedildi!'), backgroundColor: Colors.green));
  }

  void _showAddPinToDayBottomSheet(List<PinModel> allUserPins) {
    final String dayKey = _activeDayIndex.toString();
    final List<String> currentDayPins = List<String>.from(_itinerary[dayKey] ?? []);
    final poolPins = allUserPins.where((pin) {
      final id = pin.id ?? pin.title;
      return _selectedPinIds.contains(id) && !currentDayPins.contains(id);
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_activeDayIndex. Gün İçin Mekan Seç', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              poolPins.isEmpty
                  ? const Expanded(child: Center(child: Text('Tüm mekanlar atandı veya havuz boş.', style: TextStyle(color: Colors.grey))))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: poolPins.length,
                        itemBuilder: (context, index) {
                          final pin = poolPins[index];
                          final id = pin.id ?? pin.title;
                          return ListTile(
                            leading: Icon(Icons.location_on, color: Color(pin.color)),
                            title: Text(pin.title),
                            trailing: const Icon(Icons.add_circle, color: Colors.green),
                            onTap: () {
                              _addPinToDay(id, _activeDayIndex);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalDays = widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    final Color activeTheme = Color(_themeColor); 

    return StreamBuilder<List<PinModel>>(
      stream: _databaseService.getUserPins(),
      builder: (context, snapshot) {
        final allPins = snapshot.data ?? [];

        return DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(widget.trip.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: _showColorPicker,
                  icon: const Icon(Icons.color_lens),
                  color: activeTheme,
                  tooltip: 'Tema Rengi Seç',
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                labelColor: activeTheme,
                unselectedLabelColor: Colors.grey,
                indicatorColor: activeTheme,
                tabs: const [
                  Tab(icon: Icon(Icons.place), text: 'Pin Havuzu'),
                  Tab(icon: Icon(Icons.calendar_view_day), text: 'Günlük Plan'),
                  Tab(icon: Icon(Icons.note_alt), text: 'Notlar'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // 1. SEKME: PİN HAVUZU
                allPins.isEmpty
                    ? const Center(child: Text('Haritada henüz kaydedilmiş bir yer yok.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: allPins.length,
                        itemBuilder: (context, index) {
                          final pin = allPins[index];
                          final pinId = pin.id ?? pin.title;
                          final isSelected = _selectedPinIds.contains(pinId);

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: CheckboxListTile(
                              activeColor: activeTheme,
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              secondary: CircleAvatar(backgroundColor: Color(pin.color).withOpacity(0.15), child: Icon(Icons.location_on, color: Color(pin.color))),
                              title: Text(pin.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(pin.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                              value: isSelected,
                              onChanged: (bool? value) => _togglePinSelection(pinId),
                            ),
                          );
                        },
                      ),
                
                // 2. SEKME: GÜNLÜK PLAN
                Column(
                  children: [
                    // Akıllı Dağıt AI Banner'ı
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: activeTheme.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeTheme.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: activeTheme, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Akıllı Dağıt', style: TextStyle(fontWeight: FontWeight.bold, color: activeTheme, fontSize: 14)),
                                const SizedBox(height: 2),
                                const Text('Sabitlenenleri koru, kalanları yakınlığa göre böl', style: TextStyle(fontSize: 11, color: Colors.black87)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeTheme, 
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () => _optimizeAllDaysRoute(allPins, totalDays),
                            child: const Text('Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),

                    Container(
                      height: 60,
                      color: Colors.transparent,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        itemCount: totalDays,
                        itemBuilder: (context, index) {
                          final dayNum = index + 1;
                          final isSelected = _activeDayIndex == dayNum;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('$dayNum. Gün'),
                              selected: isSelected,
                              selectedColor: activeTheme,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                              onSelected: (bool selected) { if (selected) setState(() => _activeDayIndex = dayNum); },
                            ),
                          );
                        },
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Sıralamak için basılı tutun', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic))),
                          TextButton.icon(
                            onPressed: () => _showBulkMoveDialog(totalDays),
                            icon: Icon(Icons.move_to_inbox, size: 16, color: activeTheme),
                            label: Text('Günü Komple Taşı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeTheme)),
                            style: TextButton.styleFrom(backgroundColor: activeTheme.withOpacity(0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final String dayKey = _activeDayIndex.toString();
                          final List<String> currentDayPinIds = List<String>.from(_itinerary[dayKey] ?? []);
                          final dayPins = allPins.where((p) => currentDayPinIds.contains(p.id ?? p.title)).toList();
                          dayPins.sort((a, b) => currentDayPinIds.indexOf(a.id ?? a.title).compareTo(currentDayPinIds.indexOf(b.id ?? b.title)));

                          if (dayPins.isEmpty) return const Center(child: Text('Bu gün için plan yok.', style: TextStyle(color: Colors.grey)));

                          return ReorderableListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: dayPins.length,
                            onReorder: _onReorderPins,
                            itemBuilder: (context, index) {
                              final pin = dayPins[index];
                              final id = pin.id ?? pin.title;
                              final isPinned = _lockedPins.containsKey(id);
                              
                              return Card(
                                key: ValueKey(id),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pop(context, pin);
                                  },
                                  leading: CircleAvatar(backgroundColor: activeTheme.withOpacity(0.1), child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: activeTheme))),
                                  title: Text(pin.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(pin.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // YENİ: Sabitleme / Kilit Butonu (Icons.push_pin)
                                      IconButton(
                                        icon: Icon(
                                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                          color: isPinned ? activeTheme : Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () => _togglePinLock(id),
                                        tooltip: isPinned ? 'Kilidi Kaldır' : 'Bu Güne Sabitle',
                                      ),
                                      PopupMenuButton<int>(
                                        icon: const Icon(Icons.calendar_month, color: Colors.blueGrey, size: 20),
                                        onSelected: (int targetDay) => _moveSinglePinToAnotherDay(id, _activeDayIndex, targetDay),
                                        itemBuilder: (context) => List.generate(totalDays, (i) => i + 1).where((d) => d != _activeDayIndex)
                                            .map((d) => PopupMenuItem<int>(value: d, child: Text('$d. Gün\'e Taşı'))).toList(),
                                      ),
                                      IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20), onPressed: () => _removePinFromDay(id, _activeDayIndex)),
                                      const Icon(Icons.drag_handle, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddPinToDayBottomSheet(allPins),
                          icon: const Icon(Icons.add_location_alt),
                          label: Text('$_activeDayIndex. Güne Mekan Ekle', style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: activeTheme, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. SEKME: NOTLAR
                Padding(
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
                            hintText: 'Aklına gelen her şeyi buraya karalayabilirsin...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveNotes,
                          icon: const Icon(Icons.save),
                          label: const Text('Notları Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: activeTheme, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}