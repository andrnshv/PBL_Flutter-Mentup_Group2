import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/landing_model.dart';

class MentorLandingController {
  final SupabaseClient _supabase = Supabase.instance.client;

  MentorProfileSummary? profile;
  List<MentorBookingRequestItem> paidBookings = [];
  List<MentorUpcomingSession> confirmedSessions = [];
  List<MentorReviewItem> reviews = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAll() async {
    final mentorId = _supabase.auth.currentUser?.id;
    if (mentorId == null) {
      errorMessage = 'User not authenticated.';
      isLoading = false;
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await Future.wait([
        _fetchProfile(mentorId),
        _fetchPaidBookings(mentorId),
        _fetchConfirmedSessions(mentorId),
        _fetchReviews(mentorId),
      ]);
    } finally {
      isLoading = false;
    }
  }

  // ── Profile mentor ────────────────────────────────────
  Future<void> _fetchProfile(String mentorId) async {
    try {
      final res = await _supabase
          .from('bio_profil')
          .select('nama_lengkap, foto_url')
          .eq('user_id', mentorId)
          .maybeSingle();

      if (res != null) {
        profile = MentorProfileSummary.fromJson(res as Map<String, dynamic>);
      } else {
        final meta = _supabase.auth.currentUser?.userMetadata;
        profile = MentorProfileSummary(
          nama: meta?['nama_lengkap'] as String? ?? 'Mentor',
          fotoUrl: null,
        );
      }
    } catch (e) {
      profile = const MentorProfileSummary(nama: 'Mentor');
    }
  }

  // ── Paid bookings (max 3) ────────────────────────────
  Future<void> _fetchPaidBookings(String mentorId) async {
    try {
      final res = await _supabase
          .from('bookings')
          .select('''
            id,
            session_start_time,
            session_end_time,
            appuser:client_id (
              id,
              nama_lengkap,
              email
            ),
            mentor_schedules:schedule_id (
              available_date
            )
          ''')
          .eq('mentor_id', mentorId)
          .eq('booking_status', 'paid')
          .order('created_at', ascending: false)
          .limit(3);

      final List<Map<String, dynamic>> raw =
          List<Map<String, dynamic>>.from(res as List);

      final emails = raw
          .map((b) =>
              (b['appuser'] as Map<String, dynamic>?)?['email'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, foto_url, categories ( category_name )')
            .inFilter('email', emails);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) bioMap[email] = bio;
        }
      }

      paidBookings = raw.map((b) {
        final client = b['appuser'] as Map<String, dynamic>?;
        final email = client?['email'] as String?;
        final bio = email != null ? bioMap[email] : null;
        final rawCat = bio?['categories'];
        String? categoryName;
        if (rawCat is Map) {
          categoryName = rawCat['category_name'] as String?;
        } else if (rawCat is List && rawCat.isNotEmpty) {
          categoryName = (rawCat.first as Map)['category_name'] as String?;
        }

        return MentorBookingRequestItem.fromJson({
          ...b,
          'foto_url': bio?['foto_url'],
          'category_name': categoryName,
        });
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      paidBookings = [];
    } catch (e) {
      paidBookings = [];
    }
  }

  // ── Confirmed sessions (max 3) ────────────────────────
  Future<void> _fetchConfirmedSessions(String mentorId) async {
    try {
      // Query 1: bookings confirmed
      final res = await _supabase
          .from('bookings')
          .select('''
            id,
            session_start_time,
            session_end_time,
            client_address,
            appuser:client_id (
              id,
              nama_lengkap,
              email
            ),
            mentor_schedules:schedule_id (
              available_date
            )
          ''')
          .eq('mentor_id', mentorId)
          .eq('booking_status', 'confirmed')
          .order('created_at', ascending: true)
          .limit(3);

      final List<Map<String, dynamic>> raw =
          List<Map<String, dynamic>>.from(res as List);

      if (raw.isEmpty) {
        confirmedSessions = [];
        return;
      }

      // Query 2: bio_profil via email
      final emails = raw
          .map((b) =>
              (b['appuser'] as Map<String, dynamic>?)?['email'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, categories ( category_name )')
            .inFilter('email', emails);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) bioMap[email] = bio;
        }
      }

      confirmedSessions = raw.map((b) {
        final client = b['appuser'] as Map<String, dynamic>?;
        final email = client?['email'] as String?;
        final bio = email != null ? bioMap[email] : null;
        final rawCat = bio?['categories'];
        String? categoryName;
        if (rawCat is Map) {
          categoryName = rawCat['category_name'] as String?;
        } else if (rawCat is List && rawCat.isNotEmpty) {
          categoryName = (rawCat.first as Map)['category_name'] as String?;
        }

        return MentorUpcomingSession.fromJson({
          ...b,
          'category_name': categoryName,
        });
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      confirmedSessions = [];
    } catch (e) {
      confirmedSessions = [];
    }
  }

  // ── Reviews milik mentor (max 5) ─────────────────────
  Future<void> _fetchReviews(String mentorId) async {
    try {
      // Query 1: reviews + nama client
      final res = await _supabase
          .from('reviews')
          .select('''
            id,
            rating,
            review_text,
            created_at,
            appuser:client_id (
              id,
              nama_lengkap,
              email
            )
          ''')
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> raw =
          List<Map<String, dynamic>>.from(res as List);

      if (raw.isEmpty) {
        reviews = [];
        return;
      }

      // Query 2: bio_profil via email untuk foto
      final emails = raw
          .map((b) =>
              (b['appuser'] as Map<String, dynamic>?)?['email'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, Map<String, dynamic>> bioMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, foto_url')
            .inFilter('email', emails);

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) bioMap[email] = bio;
        }
      }

      reviews = raw.map((b) {
        final client = b['appuser'] as Map<String, dynamic>?;
        final email = client?['email'] as String?;
        final bio = email != null ? bioMap[email] : null;

        return MentorReviewItem.fromJson({
          ...b,
          'foto_url': bio?['foto_url'],
        });
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      reviews = [];
    } catch (e) {
      reviews = [];
    }
  }
}
