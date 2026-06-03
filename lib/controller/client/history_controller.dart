import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  HISTORY CONTROLLER — MentUp
//  File: lib/controller/client/history_controller.dart
//
//  - Ambil riwayat sesi klien (Done / Cancelled)
//  - Simpan review (rating + komentar) ke tabel `reviews`
//  - Review yang disimpan otomatis muncul di Top Mentors & What They Say
// ================================================================

class HistoryItemModel {
  final String bookingId;
  final String mentorId;
  final String name;
  final String role; // kategori mentor
  final String? fotoUrl;
  final String dateLabel;
  final String status; // 'Done' | 'Cancelled'
  bool isReviewed; // sudah kasih review?
  int? rating; // rating yang sudah diberikan
  String? review; // komentar yang sudah diberikan

  HistoryItemModel({
    required this.bookingId,
    required this.mentorId,
    required this.name,
    required this.role,
    required this.dateLabel,
    required this.status,
    this.fotoUrl,
    this.isReviewed = false,
    this.rating,
    this.review,
  });
}

class HistoryController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<HistoryItemModel> doneList = [];
  List<HistoryItemModel> cancelledList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchHistory() async {
    isLoading = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      // Ambil booking yang sudah selesai / dibatalkan
      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status, created_at,
            mentor_schedules ( available_date, start_time )
          ''')
          .eq('client_id', userId)
          .inFilter('booking_status',
              ['done', 'completed', 'cancelled', 'canceled', 'failed'])
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(bookings);

      // Nama + foto + kategori mentor
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

      // Review yang sudah dibuat klien ini (untuk tahu booking mana
      // yang sudah direview). Kita pakai mentor_id + client_id.
      final reviews = await _supabase
          .from('reviews')
          .select('mentor_id, rating, review_text')
          .eq('client_id', userId);

      final Map<String, Map<String, dynamic>> reviewMap = {};
      for (final r in List<Map<String, dynamic>>.from(reviews)) {
        final mid = r['mentor_id'] as String?;
        if (mid != null) reviewMap[mid] = r;
      }

      final done = <HistoryItemModel>[];
      final cancelled = <HistoryItemModel>[];

      for (final b in list) {
        final mentorId = b['mentor_id'] as String? ?? '';
        final bio = bioMap[mentorId];
        final schedule = b['mentor_schedules'] as Map<String, dynamic>?;
        final rawStatus = (b['booking_status'] as String? ?? '').toLowerCase();

        final review = reviewMap[mentorId];

        final item = HistoryItemModel(
          bookingId: b['id'] as String,
          mentorId: mentorId,
          name: bio?['nama_lengkap'] as String? ?? 'Mentor',
          role: (bio?['categories'] as Map<String, dynamic>?)?['category_name']
                  as String? ??
              'Mentor',
          fotoUrl: bio?['foto_url'] as String?,
          dateLabel: _fmtDate(schedule?['available_date'] as String?),
          status: (rawStatus == 'done' || rawStatus == 'completed')
              ? 'Done'
              : 'Cancelled',
          isReviewed: review != null,
          rating: (review?['rating'] as num?)?.toInt(),
          review: review?['review_text'] as String?,
        );

        if (item.status == 'Done') {
          done.add(item);
        } else {
          cancelled.add(item);
        }
      }

      doneList = done;
      cancelledList = cancelled;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat riwayat: $e';
    } finally {
      isLoading = false;
    }
  }

  // ─────────────────────────────────────────────────────
  //  Simpan review ke tabel `reviews`
  //  (rating 1-5 + komentar). Trigger DB akan update rating
  //  mentor otomatis.
  // ─────────────────────────────────────────────────────
  Future<bool> submitReview({
    required String mentorId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      final clientId = _supabase.auth.currentUser?.id;
      if (clientId == null) {
        errorMessage = 'User belum login.';
        return false;
      }

      await _supabase.from('reviews').insert({
        'mentor_id': mentorId,
        'client_id': clientId,
        'rating': rating,
        'review_text': reviewText,
      });

      return true;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = '$e';
      return false;
    }
  }

  static String _fmtDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw);
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
    } catch (_) {
      return raw;
    }
  }
}
