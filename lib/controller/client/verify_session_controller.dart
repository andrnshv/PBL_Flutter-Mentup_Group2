import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  VERIFY SESSION CONTROLLER — MentUp
//  File: lib/controller/client/verify_session_controller.dart
//
//  Mengelola sesi yang menunggu verifikasi klien.
//  Satu booking = satu sesi (1 hari), jadi 1 baris booking
//  menghasilkan 1 kartu verifikasi — walau mentornya sama.
// ================================================================

class VerifySessionItem {
  final String bookingId;
  final String mentorId;
  final String mentorName;
  final String category; // kategori/role mentor
  final String? fotoUrl;
  final String? proofUrl; // foto bukti mengajar dari mentor
  final String? summary; // ringkasan sesi dari mentor
  final String dateLabel; // "12 April 2026"
  final String timeLabel; // "13:00"

  const VerifySessionItem({
    required this.bookingId,
    required this.mentorId,
    required this.mentorName,
    required this.category,
    required this.dateLabel,
    required this.timeLabel,
    this.fotoUrl,
    this.proofUrl,
    this.summary,
  });
}

class VerifySessionController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<VerifySessionItem> pendingSessions = [];
  bool isLoading = false;
  String? errorMessage;

  // ─────────────────────────────────────────────────────
  //  Ambil sesi yang menunggu verifikasi klien.
  //  Syarat: sudah bayar (confirmed) DAN mentor sudah
  //  upload bukti → status 'awaiting_verification'.
  // ─────────────────────────────────────────────────────
  Future<void> fetchPendingVerifications() async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      // Ambil booking yang menunggu verifikasi
      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status, proof_url, session_summary,
            mentor_schedules ( available_date, start_time, end_time )
          ''')
          .eq('client_id', userId)
          .eq('booking_status', 'awaiting_verification')
          .order('proof_submitted_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(bookings);

      if (list.isEmpty) {
        pendingSessions = [];
        isLoading = false;
        return;
      }

      // Ambil data mentor (nama, foto, kategori)
      final mentorIds = list
          .map((b) => b['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (mentorIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select(
                'user_id, nama_lengkap, foto_url, categories(category_name)')
            .inFilter('user_id', mentorIds);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          bioMap[bio['user_id'] as String] = bio;
        }
      }

      pendingSessions = list.map((b) {
        final mentorId = b['mentor_id'] as String? ?? '';
        final bio = bioMap[mentorId];
        final schedule = b['mentor_schedules'] as Map<String, dynamic>?;

        return VerifySessionItem(
          bookingId: b['id'] as String,
          mentorId: mentorId,
          mentorName: bio?['nama_lengkap'] as String? ?? 'Mentor',
          category: (bio?['categories']
                  as Map<String, dynamic>?)?['category_name'] as String? ??
              'Mentor',
          fotoUrl: bio?['foto_url'] as String?,
          proofUrl: b['proof_url'] as String?,
          summary: b['session_summary'] as String?,
          dateLabel: _formatDate(schedule?['available_date'] as String?),
          timeLabel: _formatTime(schedule?['start_time'] as String?),
        );
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat sesi: $e';
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  //  Klien VERIFIKASI sesi → booking jadi 'completed'
  // ─────────────────────────────────────────────────────
  Future<bool> verifySession(String bookingId) async {
    try {
      await _supabase.from('bookings').update({
        'booking_status': 'completed',
        'verified_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
      return true;
    } catch (e) {
      errorMessage = '$e';
      return false;
    }
  }

  // ─────────────────────────────────────────────────────
  //  Klien TOLAK bukti → kembalikan ke 'confirmed'
  //  agar mentor bisa upload bukti ulang
  // ─────────────────────────────────────────────────────
  Future<bool> rejectSession(String bookingId) async {
    try {
      await _supabase.from('bookings').update({
        'booking_status': 'confirmed',
        'proof_url': null,
        'session_summary': null,
        'proof_submitted_at': null,
      }).eq('id', bookingId);
      return true;
    } catch (e) {
      errorMessage = '$e';
      return false;
    }
  }

  // ── Helpers format ──
  static String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw);
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
    } catch (_) {
      return raw;
    }
  }

  static String _formatTime(String? raw) {
    if (raw == null) return '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }
}
