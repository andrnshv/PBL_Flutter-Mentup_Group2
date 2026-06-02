import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controller/client/calendar_controller.dart';

// ================================================================
//  CALENDAR PAGE — MentUp
//  File: lib/views/client/calendar/calendar_page.dart
//
//  Tampilan sama dengan desain awal. Data sesi dari Supabase
//  (booking yang sudah dibayar). Klik tanggal → list sesi ikut
//  berubah sesuai tanggal yang dipilih.
// ================================================================

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color primary = const Color(0xFF6C63FF);
  final CalendarController _controller = CalendarController();

  DateTime today = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchSessions();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Sesi untuk tanggal yang sedang dipilih
    final daySessions = _controller.sessionsForDay(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= BACK + TITLE =================
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Calender",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// ================= CALENDAR =================
              TableCalendar(
                focusedDay: today,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                selectedDayPredicate: (day) => isSameDay(day, today),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    today = selectedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  // Marker titik untuk tanggal yang ada sesi
                  markerBuilder: (context, day, _) {
                    final hasSession = _controller.daysWithSession
                        .any((d) => isSameDay(d, day));
                    if (hasSession) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false, // sembunyikan tombol "2 weeks"
                  titleCentered: true,
                ),
              ),

              const SizedBox(height: 20),

              /// ================= SESSION TITLE =================
              Container(
                height: 3,
                color: primary,
              ),
              const SizedBox(height: 10),

              const Text(
                "Sesion for today",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),

              const SizedBox(height: 10),

              /// ================= SESSION LIST =================
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (daySessions.isEmpty
                        ? _emptyState()
                        : ListView(
                            children: daySessions.map((s) {
                              return _SessionItem(
                                name: s.mentorName,
                                date: s.dateLabel,
                                time: s.timeLabel,
                              );
                            }).toList(),
                          )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Tidak ada sesi di tanggal ini",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// ================= COMPONENT SESSION ITEM =================
class _SessionItem extends StatelessWidget {
  final String name;
  final String date;
  final String time;

  const _SessionItem({
    required this.name,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sesion with $name",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}
