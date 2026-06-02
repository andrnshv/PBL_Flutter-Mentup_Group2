import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  NOTIFICATION CONTROLLER — MentUp
//  File: lib/controller/client/notification_controller.dart
//
//  Mengumpulkan 3 jenis notifikasi dari Supabase:
//   1. Upcoming Session   → booking dibayar (confirmed), jadwal MASIH mendatang
//   2. New Mentor Available → mentor yang punya slot tersedia HARI INI
//   3. Booking Confirmed  → booking yang sudah dibayar & di-ACC mentor
// ================================================================

class NotificationItemModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time; // "10 menit lalu", "Hari ini", dll
  final DateTime sortTime; // untuk urutan

  const NotificationItemModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.sortTime,
  });
}

class NotificationController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<NotificationItemModel> notifications = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchNotifications() async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
      final result = <NotificationItemModel>[];

      // ── Ambil booking klien yang sudah dibayar ──
      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status, created_at,
            mentor_schedules ( available_date, start_time )
          ''')
          .eq('client_id', userId)
          .inFilter(
              'booking_status', ['confirmed', 'awaiting_verification', 'done']);

      final bookingList = List<Map<String, dynamic>>.from(bookings);

      // Kumpulkan nama mentor
      final mentorIds = bookingList
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

      for (final b in bookingList) {
        final mentorId = b['mentor_id'] as String? ?? '';
        final name = nameMap[mentorId] ?? 'Mentor';
        final schedule = b['mentor_schedules'] as Map<String, dynamic>?;
        final dateStr = schedule?['available_date'] as String?;
        final startTime = _fmtTime(schedule?['start_time'] as String?);
        final status = b['booking_status'] as String? ?? '';

        DateTime? sessionDate;
        if (dateStr != null) {
          try {
            sessionDate = DateTime.parse(dateStr);
          } catch (_) {}
        }

        // ── 1. UPCOMING SESSION (jadwal masih mendatang) ──
        if (sessionDate != null &&
            (status == 'confirmed' || status == 'awaiting_verification')) {
          final sessionStart =
              DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
          final todayMidnight = DateTime(now.year, now.month, now.day);

          if (!sessionStart.isBefore(todayMidnight)) {
            result.add(NotificationItemModel(
              icon: Icons.calendar_today,
              title: 'Upcoming Session',
              subtitle: 'Kamu punya sesi dengan $name'
                  '${startTime.isNotEmpty ? ' pukul $startTime' : ''}.',
              time: _relativeDate(sessionDate),
              sortTime: sessionDate,
            ));
          }
        }

        // ── 3. BOOKING CONFIRMED (sudah dibayar & di-ACC) ──
        if (status == 'confirmed') {
          DateTime created;
          try {
            created = DateTime.parse(b['created_at'] as String);
          } catch (_) {
            created = now;
          }
          result.add(NotificationItemModel(
            icon: Icons.check_circle,
            title: 'Booking Confirmed',
            subtitle: 'Booking kamu dengan $name sudah dikonfirmasi.',
            time: _relativeTime(created),
            sortTime: created,
          ));
        }
      }

      // ── 2. NEW MENTOR AVAILABLE (slot tersedia HARI INI) ──
      final todaySlots = await _supabase
          .from('mentor_schedules')
          .select('mentor_id, available_date')
          .eq('available_date', todayStr)
          .eq('is_booked', false);

      final slotList = List<Map<String, dynamic>>.from(todaySlots);
      final availableMentorIds = slotList
          .map((s) => s['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (availableMentorIds.isNotEmpty) {
        // Ambil nama + kategori mentor yang available hari ini
        final bios = await _supabase
            .from('bio_profil')
            .select('user_id, nama_lengkap, categories(category_name)')
            .inFilter('user_id', availableMentorIds);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final mName = bio['nama_lengkap'] as String? ?? 'Mentor';
          final cat = (bio['categories']
                  as Map<String, dynamic>?)?['category_name'] as String? ??
              'mentoring';
          result.add(NotificationItemModel(
            icon: Icons.star,
            title: 'New Mentor Available',
            subtitle: '$mName tersedia hari ini untuk $cat.',
            time: 'Hari ini',
            sortTime: now,
          ));
        }
      }

      // Urutkan: terbaru di atas
      result.sort((a, b) => b.sortTime.compareTo(a.sortTime));

      notifications = result;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat notifikasi: $e';
    } finally {
      isLoading = false;
    }
  }

  // ── Helpers ──
  static String _fmtTime(String? raw) {
    if (raw == null) return '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  // "10 menit lalu" / "2 jam lalu" / "Kemarin" / "3 hari lalu"
  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  // Untuk jadwal mendatang: "Hari ini" / "Besok" / "12 Mei 2026"
  static String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
