import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/trip_model.dart';
import 'trip_detail_screen.dart';


class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _showAddTripDialog() async {
    final TextEditingController titleController = TextEditingController();
    DateTimeRange? selectedDateRange;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Yeni Seyahat Klasörü'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Seyahat Adı (Örn: Roma Turu)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: const Icon(Icons.date_range, color: Colors.deepOrange),
                    title: Text(
                      selectedDateRange == null
                          ? 'Tarih Aralığı Seç'
                          : '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}',
                    ),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepOrange,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDateRange = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty || selectedDateRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen isim ve tarih seçin.')),
                      );
                      return;
                    }
                    
                    final newTrip = TripModel(
                      userId: _currentUserId,
                      title: titleController.text.trim(),
                      startDate: selectedDateRange!.start,
                      endDate: selectedDateRange!.end,
                    );
                    
                    Navigator.pop(context);
                    await _databaseService.addTrip(newTrip);
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Seyahat Planlarım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.deepOrange),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.deepOrange),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          Expanded(
            child: StreamBuilder<List<TripModel>>(
              stream: _databaseService.getUserTrips(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                }
                
                final trips = snapshot.data ?? [];
                
                if (trips.isEmpty) {
                  return const Center(
                    child: Text('Henüz planlanmış bir seyahat yok.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    final duration = trip.endDate.difference(trip.startDate).inDays + 1;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () async {
                          // YENİ: Detay sayfasından dönen pini "resultPin" olarak yakalar
                          final resultPin = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailScreen(trip: trip),
                            ),
                          );
                          
                          // Eğer bir pin seçildiyse, onu alıp bir önceki sayfaya fırlatır
                          if (resultPin != null && context.mounted) {
                            Navigator.pop(context, resultPin);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.folder_special, color: Colors.deepOrange, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${DateFormat('dd MMM').format(trip.startDate)} - ${DateFormat('dd MMM').format(trip.endDate)}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$duration Gün', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTripDialog,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}