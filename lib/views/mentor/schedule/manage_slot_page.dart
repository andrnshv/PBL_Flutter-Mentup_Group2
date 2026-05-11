import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
// --- TAMBAHAN IMPORT KALENDER ---
import 'package:table_calendar/table_calendar.dart';

class ManageSlotPage extends StatefulWidget {
  const ManageSlotPage({super.key});

  @override
  State<ManageSlotPage> createState() => _ManageSlotPageState();
}

class _ManageSlotPageState extends State<ManageSlotPage> {
  final Color primaryColor = const Color(0xFF5B62CC);
  final Color backgroundColor = const Color(0xFFF4F6FA);

  // --- STATE UNTUK KALENDER ---
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Struktur data diubah menjadi berbasis DateTime, bukan lagi String nama hari
  Map<DateTime, List<Map<String, TimeOfDay>>> availabilityWindows = {};

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // Fungsi helper untuk mengubah format tanggal menjadi cantik tanpa package intl
  String _formatDate(DateTime date) {
    List<String> months = [
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
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  // Fungsi untuk menormalkan tanggal (membuang jam/menit/detik) agar seragam di Map
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- LOGIKA VALIDASI & INPUT JAM ---
  Future<void> _pickTimeRange(DateTime rawDate) async {
    DateTime date = _normalizeDate(rawDate);

    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) return;

    TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (end == null) return;

    int newStart = _toMinutes(start);
    int newEnd = _toMinutes(end);

    // 1. Validasi: Waktu selesai harus setelah waktu mulai
    if (newEnd <= newStart) {
      CherryToast.error(
        title: const Text(
          "Invalid Time",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "End time must be after start time.",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    // --- 2. VALIDASI BARU: MINIMAL 1 JAM (60 MENIT) ---
    int duration = newEnd - newStart;
    if (duration < 60) {
      CherryToast.warning(
        title: const Text(
          "Duration Too Short",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "The minimum duration of the session is 1 hour.",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    // 3. Validasi: Cek Overlap (Tumpang tindih)
    bool isOverlapping = false;
    if (availabilityWindows.containsKey(date)) {
      for (var existingRange in availabilityWindows[date]!) {
        int exStart = _toMinutes(existingRange['start']!);
        int exEnd = _toMinutes(existingRange['end']!);
        if (newStart < exEnd && newEnd > exStart) {
          isOverlapping = true;
          break;
        }
      }
    }

    if (isOverlapping) {
      CherryToast.warning(
        title: const Text(
          "Overlap Detected",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "This time range overlaps with an existing slot!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    // Menyimpan Data
    setState(() {
      if (!availabilityWindows.containsKey(date)) {
        availabilityWindows[date] = [];
      }
      availabilityWindows[date]!.add({"start": start, "end": end});
      availabilityWindows[date]!.sort(
        (a, b) => _toMinutes(a['start']!).compareTo(_toMinutes(b['start']!)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Manage Availability",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // --- GUIDELINE CARD (TIDAK DIUBAH) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.8), primaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Guideline",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Select a specific date on the calendar, then set your available hours. Past dates are automatically blocked.",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- INTERACTIVE CALENDAR & SLOTS ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                // Container Kalender
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: TableCalendar(
                    // Logika memblokir hari kemarin
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
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
                    // Menampilkan titik di kalender jika hari itu punya slot
                    eventLoader: (day) {
                      return availabilityWindows[_normalizeDate(day)] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      // Desain titik/marker
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFFE24A7C), // Pink pastel
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Header untuk Slot di Tanggal Terpilih
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Slots for ${_formatDate(_selectedDay!)}",
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: primaryColor,
                        size: 30,
                      ),
                      onPressed: () => _pickTimeRange(_selectedDay!),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Daftar Slot
                _buildSlotList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // --- WIDGET LIST SLOT ---
  Widget _buildSlotList() {
    DateTime normalizedDate = _normalizeDate(_selectedDay!);
    List<Map<String, TimeOfDay>> ranges =
        availabilityWindows[normalizedDate] ?? [];

    if (ranges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, color: Colors.grey[400], size: 40),
            const SizedBox(height: 10),
            Text(
              "No slots available for this date.",
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

    return Column(
      children: ranges
          .map(
            (range) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${_formatTime(range['start']!)} - ${_formatTime(range['end']!)}",
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        availabilityWindows[normalizedDate]!.remove(range);
                        // Bersihkan key tanggal jika array slot-nya kosong (supaya titik kalender hilang)
                        if (availabilityWindows[normalizedDate]!.isEmpty) {
                          availabilityWindows.remove(normalizedDate);
                        }
                      });
                    },
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // --- SAVE BUTTON (TIDAK DIUBAH) ---
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () {
          CherryToast.success(
            title: const Text(
              "Success",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
            description: const Text(
              "Availability schedule saved successfully!",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
            autoDismiss: true,
            onToastClosed: () => Navigator.pop(context),
          ).show(context);
        },
        child: const Text(
          "Save Schedule Changes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
