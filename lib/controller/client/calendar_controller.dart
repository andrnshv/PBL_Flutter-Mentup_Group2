import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  CALENDAR CONTROLLER — MentUp
//  File: lib/controller/client/calendar_controller.dart
//
//  Mengambil jadwal sesi klien (booking yang SUDAH dibayar)
//  dari Supabase, untuk ditampilkan di CalendarPage.
//  "Session for today" tampil sesuai tanggal yang dipilih.
// ================================================================

class SessionItemModel {
  final String bookingId;
  final String mentorName;
  final String dateLabel; // "12 Mei 2026"
  final String timeLabel; // "11:00 - 13:00"
  final DateTime date; // tanggal asli (untuk filter per hari)
  final String status; // booking_status

  const SessionItemModel({
    required this.bookingId,
    required this.mentorName,
    required this.dateLabel,
    required this.timeLabel,
    required this.date,
    required this.status,
  });
}

class CalendarController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<SessionItemModel> allSessions = [];
  bool isLoading = false;
  String? errorMessage;

  // ─────────────────────────────────────────────────────
  //  Ambil semua sesi klien yang sudah dibayar
  //  (confirmed / awaiting_verification / done)
  // ─────────────────────────────────────────────────────
  Future<void> fetchSessions() async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      // Ambil booking yang sudah dibayar + jadwalnya
      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status,
            mentor_schedules ( available_date, start_time, end_time )
          ''')
          .eq('client_id', userId)
          .inFilter(
              'booking_status', ['confirmed', 'awaiting_verification', 'done']);

      final list = List<Map<String, dynamic>>.from(bookings);

      if (list.isEmpty) {
        allSessions = [];
        isLoading = false;
        return;
      }

      // Ambil nama mentor
      final mentorIds = list
          .map((b) => b['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, String> nameMap = {};
      if (mentorIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('user_id, nama_lengkap')
            .inFilter('user_id', mentorIds);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          nameMap[bio['user_id'] as String] =
              bio['nama_lengkap'] as String? ?? 'Mentor';
        }
      }

      final sessions = <SessionItemModel>[];
      for (final b in list) {
        final schedule = b['mentor_schedules'] as Map<String, dynamic>?;
        final dateStr = schedule?['available_date'] as String?;
        if (dateStr == null) continue;

        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(dateStr);
        } catch (_) {
          continue;
        }

        final mentorId = b['mentor_id'] as String? ?? '';
        final start = _fmtTime(schedule?['start_time'] as String?);
        final end = _fmtTime(schedule?['end_time'] as String?);

        sessions.add(SessionItemModel(
          bookingId: b['id'] as String,
          mentorName: nameMap[mentorId] ?? 'Mentor',
          dateLabel: _fmtDate(parsedDate),
          timeLabel: end.isNotEmpty ? '$start - $end' : start,
          date: parsedDate,
          status: b['booking_status'] as String? ?? '',
        ));
      }

      allSessions = sessions;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat jadwal: $e';
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  //  Filter sesi untuk tanggal tertentu
  // ─────────────────────────────────────────────────────
  List<SessionItemModel> sessionsForDay(DateTime day) {
    return allSessions
        .where((s) =>
            s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day)
        .toList()
      ..sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
  }

  // ─────────────────────────────────────────────────────
  //  Set tanggal yang punya sesi (untuk marker di kalender)
  // ─────────────────────────────────────────────────────
  Set<DateTime> get daysWithSession {
    return allSessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
  }

  // ── Helpers ──
  static String _fmtTime(String? raw) {
    if (raw == null) return '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  static String _fmtDate(DateTime dt) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
