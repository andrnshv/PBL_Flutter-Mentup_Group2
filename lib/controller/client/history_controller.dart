import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryItemModel {
  final String  bookingId;
  final String? bookingHistoryId; // ← field, bukan hilang setelah konstruktor
  final String  mentorId;
  final String  name;
  final String  role;
  final String? fotoUrl;
  final String  dateLabel;
  final String  status;
  final String  rawStatus;
  final String? cancelReason;
  bool    isReviewed;
  int?    rating;
  String? review;

  HistoryItemModel({
    required this.bookingId,
    this.bookingHistoryId,         // ← nullable, diisi kalau ada
    required this.mentorId,
    required this.name,
    required this.role,
    required this.dateLabel,
    required this.status,
    required this.rawStatus,
    this.cancelReason,
    this.fotoUrl,
    this.isReviewed = false,
    this.rating,
    this.review,
  });

  String get statusLabel {
    switch (rawStatus) {
      case 'rejected':              return 'Rejected';
      case 'reschedule':            return 'Rescheduled';
      case 'failed':                return 'Failed';
      case 'cancelled':
      case 'canceled':              return 'Cancelled';
      case 'done':
      case 'completed':             return 'Done';
      default:                      return status;
    }
  }

  bool get isRejected => rawStatus == 'rejected';
}

// ─────────────────────────────────────────────────────────────────
class HistoryController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<HistoryItemModel> doneList      = [];
  List<HistoryItemModel> cancelledList = [];
  bool    isLoading    = false;
  String? errorMessage;

  Future<void> fetchHistory() async {
    isLoading    = true;
    errorMessage = null;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User belum login.';
        isLoading = false;
        return;
      }

      // ── Query 1: bookings ──────────────────────────────────
      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status, created_at, notes,
            mentor_schedules(available_date, start_time)
          ''')
          .eq('client_id', userId)
          .inFilter('booking_status', [
            'done', 'completed',
            'cancelled', 'canceled',
            'failed', 'rejected',
          ])
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(bookings);
      final bookingIds = list.map((b) => b['id'] as String).toList();

      // ── Query 2: booking_histories (untuk dapat ID-nya) ────
      // Key: booking_id → history_id
      final Map<String, String> historyIdMap = {};
      if (bookingIds.isNotEmpty) {
        final histories = await _supabase
            .from('booking_histories')
            .select('id, booking_id')
            .inFilter('booking_id', bookingIds);

        for (final h in List<Map<String, dynamic>>.from(histories)) {
          final bid = h['booking_id'] as String?;
          final hid = h['id']         as String?;
          if (bid != null && hid != null) historyIdMap[bid] = hid;
        }
      }

      // ── Query 3: bio_profil mentor ────────────────────────
      final mentorIds = list
          .map((b) => b['mentor_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (mentorIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('user_id, nama_lengkap, foto_url, categories(category_name)')
            .inFilter('user_id', mentorIds);
        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          bioMap[bio['user_id'] as String] = bio;
        }
      }

      // ── Query 4: reviews — key by booking_history_id ──────
      // Pakai booking_history_id agar per-booking, bukan per-mentor
      final historyIds = historyIdMap.values.toList();
      final Map<String, Map<String, dynamic>> reviewMap = {};
      if (historyIds.isNotEmpty) {
        final reviews = await _supabase
            .from('reviews')
            .select('booking_history_id, rating, review_text')
            .eq('client_id', userId)
            .inFilter('booking_history_id', historyIds);

        for (final r in List<Map<String, dynamic>>.from(reviews)) {
          final hid = r['booking_history_id'] as String?;
          if (hid != null) reviewMap[hid] = r;
        }
      }

      // ── Bangun model ──────────────────────────────────────
      final done      = <HistoryItemModel>[];
      final cancelled = <HistoryItemModel>[];

      for (final b in list) {
        final mentorId   = b['mentor_id']       as String? ?? '';
        final bookingId  = b['id']              as String;
        final bio        = bioMap[mentorId];
        final schedule   = b['mentor_schedules'] as Map<String, dynamic>?;
        final rawStatus  = (b['booking_status'] as String? ?? '').toLowerCase();
        final isDone     = rawStatus == 'done' || rawStatus == 'completed';

        // Cari history_id untuk booking ini
        final historyId  = historyIdMap[bookingId];
        // Cari review berdasarkan history_id (bukan mentor_id!)
        final review     = historyId != null ? reviewMap[historyId] : null;

        final item = HistoryItemModel(
          bookingId:        bookingId,
          bookingHistoryId: historyId,   // ← tersimpan di field
          mentorId:         mentorId,
          name:     bio?['nama_lengkap'] as String? ?? 'Mentor',
          role: (bio?['categories'] as Map<String, dynamic>?)?['category_name']
                  as String? ?? 'Mentor',
          fotoUrl:      bio?['foto_url']   as String?,
          dateLabel:    _fmtDate(schedule?['available_date'] as String?),
          status:       isDone ? 'Done' : 'Cancelled',
          rawStatus:    rawStatus,
          cancelReason: rawStatus == 'rejected' ? b['notes'] as String? : null,
          isReviewed:   review != null,
          rating:       (review?['rating']      as num?)?.toInt(),
          review:       review?['review_text']  as String?,
        );

        isDone ? done.add(item) : cancelled.add(item);
      }

      doneList      = done;
      cancelledList = cancelled;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat riwayat: $e';
    } finally {
      isLoading = false;
    }
  }

  // ── Cancel booking rejected ───────────────────────────────────
  Future<String?> cancelRejected(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'booking_status': 'cancelled'})
          .eq('id', bookingId);
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return '$e';
    }
  }

  // ── Submit review ─────────────────────────────────────────────
  // bookingHistoryId wajib ada — tanpa itu FK constraint akan error
  Future<bool> submitReview({
    required String  mentorId,
    required String? bookingHistoryId,   // ← dari item.bookingHistoryId
    required int     rating,
    required String  reviewText,
  }) async {
    if (bookingHistoryId == null || bookingHistoryId.isEmpty) {
      errorMessage =
          'Booking history tidak ditemukan. Sesi ini mungkin belum selesai diverifikasi.';
      return false;
    }

    try {
      final clientId = _supabase.auth.currentUser?.id;
      if (clientId == null) {
        errorMessage = 'User belum login.';
        return false;
      }

      await _supabase.from('reviews').insert({
        'booking_history_id': bookingHistoryId,  // ← benar, tidak null
        'mentor_id':          mentorId,
        'client_id':          clientId,
        'rating':             rating,
        'review_text':        reviewText,
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
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}