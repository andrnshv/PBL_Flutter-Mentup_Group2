import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  HISTORY CONTROLLER — MentUp
//  File: lib/controller/client/history_controller.dart
// ================================================================

class HistoryItemModel {
  final String bookingId;
  final String mentorId;
  final String name;
  final String role;
  final String? fotoUrl;
  final String dateLabel;
  final String status; // 'Done' | 'Cancelled'
  final String rawStatus; // nilai DB asli
  final String? cancelReason; // alasan reject dari mentor (notes)
  bool isReviewed;
  int? rating;
  String? review;

  HistoryItemModel({
    required this.bookingId,
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
      case 'rejected':
        return 'Rejected';
      case 'reschedule':
        return 'Rescheduled';
      case 'failed':
        return 'Failed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'done':
      case 'completed':
        return 'Done';
      default:
        return status;
    }
  }

  /// Booking rejected oleh mentor → client bisa reschedule atau refund
  bool get isRejected => rawStatus == 'rejected';
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

      final bookings = await _supabase
          .from('bookings')
          .select('''
            id, mentor_id, booking_status, created_at, notes,
            mentor_schedules ( available_date, start_time )
          ''')
          .eq('client_id', userId)
          .inFilter('booking_status', [
            'done',
            'completed',
            'cancelled',
            'canceled',
            'failed',
            'rejected',
          ])
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(bookings);

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
        final isDone = rawStatus == 'done' || rawStatus == 'completed';
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
          status: isDone ? 'Done' : 'Cancelled',
          rawStatus: rawStatus,
          // Alasan reject tersimpan di kolom notes
          cancelReason: rawStatus == 'rejected' ? b['notes'] as String? : null,
          isReviewed: review != null,
          rating: (review?['rating'] as num?)?.toInt(),
          review: review?['review_text'] as String?,
        );

        isDone ? done.add(item) : cancelled.add(item);
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

  /// Cancel booking rejected → status cancelled
  Future<String?> cancelRejected(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'booking_status': 'cancelled'}).eq('id', bookingId);
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return '$e';
    }
  }

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
