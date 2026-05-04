import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../routes/app_routes.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Palet Warna Mentup
  final Color primaryColor = const Color(0xFF5B62CC);
  final Color backgroundColor = const Color(
    0xFFF4F6FA,
  ); // Sedikit lebih soft dari F8F9FB

  // Fitur Search & Sort
  String _searchQuery = "";
  bool _isAscending = true;

  // Data Dummy dengan tambahan 'color' agar lebih hidup
  final List<Map<String, dynamic>> _dailySessions = [
    {
      "name": "Budi Santoso",
      "time": "13:00 - 15:00",
      "category": "Web Dev",
      "type": "Offline",
      "link": "Library Central Park",
      "isDone": true,
      "color": const Color(0xFFA7C7E7), // Biru
    },
    {
      "name": "Aiska Rahma",
      "time": "09:00 - 11:00",
      "category": "Statistics",
      "type": "Online",
      "link": "https://zoom.us/j/123456789",
      "isDone": false,
      "color": const Color(0xFFF5B3CE), // Pink
    },
    {
      "name": "Citra Kirana",
      "time": "15:30 - 17:00",
      "category": "UI/UX Design",
      "type": "Online",
      "link": "https://meet.google.com/abc",
      "isDone": false,
      "color": const Color(0xFFCDB4DB), // Ungu
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Fungsi Filter & Sorting
  List<Map<String, dynamic>> get _filteredAndSortedSessions {
    var filtered = _dailySessions.where((session) {
      final name = session['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      int comparison = a['name'].toString().compareTo(b['name'].toString());
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Schedule",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // --- BAGIAN KALENDER ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(bottom: 15, top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                weekendStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: Colors.red[300],
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.black87,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // --- BAGIAN DAFTAR SESI ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Schedule Details",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      // Tombol Manage Slot yang lebih "Pop"
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.manageSlot),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Manage Slot",
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Kotak Search & Sort (Lebih soft tanpa border keras)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: "Search client name...",
                              hintStyle: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 22,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isAscending
                                ? Icons.sort_by_alpha_rounded
                                : Icons.sort_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                          onPressed: () =>
                              setState(() => _isAscending = !_isAscending),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(child: _buildSessionList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    final displayList = _filteredAndSortedSessions;

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "No sessions found",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final session = displayList[index];
        final Color accentColor = session['color'];

        return GestureDetector(
          // --- NAVIGASI KE DETAIL ---
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.bookingDetail,
              arguments: {
                'name': session['name'],
                'cat':
                    session['category'], // Menyesuaikan key 'cat' di Detail Page
                'color': session['color'],
                'time': session['time'],
                'date': "Selected Date", // Nanti bisa ambil dari _selectedDay
                'location': session['link'],
                'note': "This session is already accepted and scheduled.",
                'totalPrice': "Paid", // Status untuk jadwal yang sudah jalan
                'hours': 2,
                'sessionsPerWeek': 2,
                'days': ['Mon', 'Wed'],
                'months': 1,
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                session['time'].split(" - ")[0],
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                height: 15,
                                width: 2,
                                color: Colors.grey[200],
                                margin: const EdgeInsets.symmetric(vertical: 4),
                              ),
                              Text(
                                session['time'].split(" - ")[1],
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  session['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    session['category'],
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: session['isDone']
                                  ? Colors.green.withOpacity(0.1)
                                  : accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              session['isDone']
                                  ? Icons.check_circle_rounded
                                  : (session['type'] == 'Online'
                                        ? Icons.videocam_rounded
                                        : Icons.location_on_rounded),
                              color: session['isDone']
                                  ? Colors.green
                                  : accentColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
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
