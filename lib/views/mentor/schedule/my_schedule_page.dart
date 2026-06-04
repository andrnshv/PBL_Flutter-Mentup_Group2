import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controller/mentor/schedule_controller.dart';
import '../../../models/mentor/schedule_model.dart';
import '../../../routes/app_routes.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  final MyScheduleController _controller = MyScheduleController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isPageLoading = true;

  static const Color _primary = Color(0xFF5B62CC);
  static const Color _bgColor = Color(0xFFF4F6FA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForDate(_selectedDay);
    });
  }

  /// Load jadwal untuk tanggal yang dipilih
  Future<void> _loadForDate(DateTime date) async {
    if (!mounted) return;
    setState(() => _isPageLoading = true);
    await _controller.fetchSchedulesForDate(date);
    if (mounted) setState(() => _isPageLoading = false);
  }

  /// Refresh seluruh data (untuk dot marker kalender)
  Future<void> _loadAll() async {
    await _controller.fetchSchedules();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
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
          _buildCalendar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildListHeader(),
                  const SizedBox(height: 15),
                  _buildSearchAndSort(),
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

  // ─────────────────────────────────────────────────────────
  // KALENDER
  // ─────────────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.only(bottom: 15, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
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

        // Dot marker pada tanggal yang punya jadwal
        eventLoader: (day) {
          final normalized = DateTime(day.year, day.month, day.day);
          return _controller.scheduledDates.contains(normalized) ? [true] : [];
        },

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadForDate(selectedDay);
        },

        onFormatChanged: (format) => setState(() => _calendarFormat = format),

        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox();
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),

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
            gradient: const LinearGradient(
              colors: [Color(0xFF7E7BB9), _primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          todayDecoration: BoxDecoration(
            color: _primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: _primary,
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
          leftChevronIcon:
              Icon(Icons.chevron_left_rounded, color: Colors.black87),
          rightChevronIcon:
              Icon(Icons.chevron_right_rounded, color: Colors.black87),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // LIST HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildListHeader() {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final label = '${weekdays[_selectedDay.weekday - 1]}, '
        '${_selectedDay.day} ${months[_selectedDay.month - 1]} '
        '${_selectedDay.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Schedule Details",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),

        // Tombol Manage Slot
        InkWell(
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.manageSlot).then((_) {
            _loadForDate(_selectedDay);
            _loadAll();
          }),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, size: 16, color: _primary),
                const SizedBox(width: 5),
                const Text(
                  "Manage Slot",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // SEARCH + SORT
  // ─────────────────────────────────────────────────────────
  Widget _buildSearchAndSort() {
    return Row(
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
              controller: _controller.searchController,
              onChanged: (value) {
                setState(() {
                  _controller.searchQuery = value;
                  _controller.applyFilter();
                });
              },
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
                suffixIcon: _controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _controller.searchController.clear();
                            _controller.searchQuery = '';
                            _controller.applyFilter();
                          });
                        },
                      )
                    : null,
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
              _controller.isAscending
                  ? Icons.sort_by_alpha_rounded
                  : Icons.sort_rounded,
              color: _primary,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _controller.isAscending = !_controller.isAscending;
                _controller.applyFilter();
              });
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // SESSION LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildSessionList() {
    if (_isPageLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _loadForDate(_selectedDay),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.filteredSchedules.isEmpty) {
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
              _controller.searchQuery.isNotEmpty
                  ? "No sessions found"
                  : "No sessions on this day",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_controller.searchQuery.isEmpty)
              Text(
                "Tap 'Manage Slot' to add a schedule",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _controller.filteredSchedules.length,
      itemBuilder: (context, index) {
        final session = _controller.filteredSchedules[index];
        final accentColor = _controller.accentColorFor(index);
        return _buildSessionCard(session, accentColor);
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // SESSION CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildSessionCard(MyScheduleModel session, Color accentColor) {
    final status = (session.bookingStatus ?? '').toLowerCase();
    final isDone = status == 'done' || status == 'completed';

    // Sesi selalu offline → ikon lokasi (atau centang kalau selesai)
    final IconData typeIcon =
        isDone ? Icons.check_circle_rounded : Icons.location_on_rounded;

    // Jam yang DITAMPILKAN besar di kolom kiri:
    //  - kalau ada jam booking client → pakai itu (data booking)
    //  - kalau tidak ada → pakai jam slot available mentor
    final bool hasBookingTime = session.sessionStartTime != null;

    final String displayStart =
        hasBookingTime ? session.sessionStartTime! : session.startTime;
    final String? displayEnd =
        hasBookingTime ? session.sessionEndTime : session.endTime;

    return GestureDetector(
      onTap: () {
        // Slot belum di-booking → tidak ada detail yang bisa dibuka
        if (session.bookingId == null) return;

        Navigator.pushNamed(
          context,
          AppRoutes.bookingDetail,
          arguments: {
            'bookingId': session.bookingId,
            'color': accentColor,
          },
        ).then((_) {
          _loadForDate(_selectedDay);
        });
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
              // Colored left bar
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
                      // Waktu sesi (jam booking client; fallback slot mentor)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayStart,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          if (displayEnd != null) ...[
                            Container(
                              height: 15,
                              width: 2,
                              color: Colors.grey[200],
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            Text(
                              displayEnd,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(width: 15),

                      // Info client
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (session.bookingId != null)
                                  ? (session.clientName ?? 'Unknown Client')
                                  : 'Available Slot',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (session.bookingId != null &&
                                session.bookingStatus != null)
                              _statusBadge(session.bookingStatus!, accentColor),
                            if (session.bookingId == null)
                              Text(
                                'No booking yet',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),

                            // Range slot available mentor (info sekunder)
                            if (hasBookingTime)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.event_available,
                                        size: 12, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Slot: ${session.timeRange}',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Alamat sesi (offline)
                            if (session.bookingId != null &&
                                session.clientAddress != null &&
                                session.clientAddress!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 12, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        session.clientAddress!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Icon status
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green.withOpacity(0.1)
                              : accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          typeIcon,
                          color: isDone ? Colors.green : accentColor,
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
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  Widget _statusBadge(String status, Color accentColor) {
    final s = status.toLowerCase();
    Color color;
    String label;

    switch (s) {
      case 'paid':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'cancelled':
      case 'canceled':
      case 'failed':
      case 'rejected':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'awaiting_verification':
        color = Colors.purple;
        label = 'Awaiting Verify';
        break;
      case 'done':
      case 'completed':
        color = Colors.blue;
        label = 'Done';
        break;
      default:
        color = accentColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
