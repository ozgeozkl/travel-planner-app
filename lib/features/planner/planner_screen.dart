import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/trip_model.dart';
import '../../services/database_service.dart';
import 'trip_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_planner/l10n/app_localizations.dart';
import 'general_notes_screen.dart';

class PlannerScreen extends StatefulWidget {
  final int initialTabIndex; 

  const PlannerScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  // === TAKVİM VE NOT DEĞİŞKENLERİ ===
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _dailyNoteController = TextEditingController();
  final TextEditingController _generalNoteController = TextEditingController();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initPrefs();
  }

  // Hafızayı başlat ve genel notu yükle
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _generalNoteController.text = _prefs?.getString('planner_general_note') ?? '';
    });
    _loadDailyNoteFor(_selectedDay!);
  }

  // Seçilen günün notunu getir
  void _loadDailyNoteFor(DateTime date) {
    if (_prefs == null) return;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    setState(() {
      _dailyNoteController.text = _prefs?.getString('note_$dateKey') ?? '';
    });
  }

  // Günlük notu kaydet
  void _saveDailyNote(String value) {
    if (_prefs == null || _selectedDay == null) return;
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    _prefs?.setString('note_$dateKey', value);
  }

  // Genel notu kaydet
  void _saveGeneralNote(String value) {
    if (_prefs == null) return;
    _prefs?.setString('planner_general_note', value);
  }
  // ===================================

  void _showCreateTripDialog() {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.plannerCreateTripTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.plannerTripTitleLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const Icon(Icons.date_range, color: Colors.deepOrange),
                    title: Text(
                      startDate == null || endDate == null
                          ? AppLocalizations.of(context)!.plannerSelectDateRange
                          : '${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}',
                    ),
                    onTap: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 1825)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          startDate = picked.start;
                          endDate = picked.end;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty ||
                            startDate == null ||
                            endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.plannerFillAllFieldsError),
                            ),
                          );
                          return;
                        }
                        final user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          final newTrip = TripModel(
                            userId: user.uid,
                            title: titleController.text.trim(),
                            startDate: startDate!,
                            endDate: endDate!,
                          );
                          await _databaseService.addTrip(newTrip);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.plannerCreateButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _toggleTripArchive(TripModel trip) async {
    final updatedTrip = TripModel(
      id: trip.id,
      userId: trip.userId,
      title: trip.title,
      startDate: trip.startDate,
      endDate: trip.endDate,
      notes: trip.notes,
      selectedPinIds: trip.selectedPinIds,
      itinerary: trip.itinerary,
      themeColor: trip.themeColor,
      lockedPins: trip.lockedPins,
      isArchived: !trip.isArchived, 
    );
    await _databaseService.updateTrip(updatedTrip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedTrip.isArchived
                ? AppLocalizations.of(context)!.plannerTripArchived
                : AppLocalizations.of(context)!.plannerTripUnarchived,
          ),
        ),
      );
    }
  }

  void _deleteTrip(TripModel trip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.plannerDeleteTripTitle),
        content: Text(AppLocalizations.of(context)!.plannerDeleteTripConfirm(trip.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.deleteButton),
          ),
        ],
      ),
    );

    if (confirm == true && trip.id != null) {
      await _databaseService.deleteTrip(trip.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,       
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.plannerAppBarTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(icon: const Icon(Icons.flight_takeoff), text: AppLocalizations.of(context)!.plannerTabActive),
              Tab(icon: const Icon(Icons.history), text: AppLocalizations.of(context)!.plannerTabPast),
            ],
          ),
        ),
        
        // EKRANI İKİYE BÖLDÜĞÜMÜZ YER
        body: StreamBuilder<List<TripModel>>(
          stream: _databaseService.getUserTrips(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allTrips = snapshot.data ?? [];
            final activeTrips = allTrips.where((t) => !t.isPast).toList();
            final pastTrips = allTrips.where((t) => t.isPast).toList();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOL TARAF: TAKVİM VE NOTLAR (Ekranda 4 birim yer kaplar)
                Expanded(
                  flex: 4,
                  child: _buildCalendarPanel(allTrips),
                ),
                
                const VerticalDivider(width: 1, thickness: 1, color: Colors.black12),
                
                // SAĞ TARAF: SEYAHAT LİSTESİ (Ekranda 6 birim yer kaplar)
                Expanded(
                  flex: 6,
                  child: TabBarView(
                    children: [
                      _buildTripList(activeTrips, isPastList: false),
                      _buildTripList(pastTrips, isPastList: true),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateTripDialog,
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.plannerNewTripFab),
        ),
      ),
    );
  }

// === YENİ EKLENEN TAKVİM VE NOTLAR PANELİ (ÇOKLU DİL DESTEKLİ) ===
  Widget _buildCalendarPanel(List<TripModel> allTrips) {
    // Çevirileri kullanmak için localizations değişkenini tanımlıyoruz
    final localizations = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 1. TAKVİM
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
              markersMaxCount: 1,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            eventLoader: (day) {
              return allTrips.where((trip) {
                final tStart = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
                final tEnd = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
                final current = DateTime(day.year, day.month, day.day);
                return current.isAfter(tStart.subtract(const Duration(days: 1))) && 
                       current.isBefore(tEnd.add(const Duration(days: 1)));
              }).toList();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  final trip = events.first as TripModel; 
                  
                  final current = DateTime(date.year, date.month, date.day);
                  final tStart = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
                  final tEnd = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);

                  if (current.isAtSameMomentAs(tStart) || current.isAtSameMomentAs(tEnd)) {
                    return const Positioned(
                      bottom: 0,
                      child: Icon(Icons.flight, size: 14, color: Colors.deepOrange),
                    );
                  } 
                  else {
                    return Positioned(
                      bottom: 0,
                      child: Text(
                        trip.title,
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.deepOrange, 
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                }
                return null;
              },
            ),
          ), 

          // 2. YENİ EKLENEN GENEL NOTLAR BUTONU (DİL DESTEKLİ)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Genel Notlar sayfasına geçiş yapıyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeneralNotesScreen()),
                );
              },
              icon: const Icon(Icons.edit_document),
              // Sabit metin yerine dil dosyasındaki generalNotesTitle değişkenini çağırıyoruz
              label: Text(
                localizations.generalNotesTitle,
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), 
                backgroundColor: Colors.deepOrange, 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<TripModel> trips, {required bool isPastList}) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPastList ? Icons.history_toggle_off : Icons.card_travel,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isPastList
                  ? AppLocalizations.of(context)!.plannerNoPastTrips
                  : AppLocalizations.of(context)!.plannerNoActiveTrips,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final themeColor = Color(trip.themeColor);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final resultPin = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailScreen(trip: trip),
                ),
              );

              if (resultPin != null && context.mounted) {
                Navigator.pop(context, resultPin);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: themeColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trip.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (val) {
                          if (val == 'archive') {
                            _toggleTripArchive(trip);
                          } else if (val == 'delete') {
                            _deleteTrip(trip);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(
                                  trip.isArchived ? Icons.unarchive : Icons.archive,
                                  size: 20,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(trip.isArchived 
                                  ? AppLocalizations.of(context)!.plannerMoveToActive 
                                  : AppLocalizations.of(context)!.plannerMoveToArchive),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 20, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.deleteButton, style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(trip.startDate)} - ${DateFormat('dd MMM yyyy').format(trip.endDate)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.place, size: 16, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context)!.plannerPlaceCount(trip.selectedPinIds.length),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: themeColor,
                        padding: EdgeInsets.zero,
                      ),
                      if (trip.isPast) ...[
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.check_circle, size: 16, color: Colors.grey),
                          label: Text(
                            AppLocalizations.of(context)!.plannerCompleted,
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}