import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/mentor_profile_model.dart';

class MentorProfileController {
  final SupabaseClient _supabase = Supabase.instance.client;

  MentorProfileModel? profileData;
  bool    isLoading    = false;
  String? errorMessage;

  // ─────────────────────────────────────────────────────
  // FETCH profile lengkap + reviews
  //
  // Query 1: appuser + bio_profil + service_rates + mentor_schedules
  // Query 2: reviews + appuser
  // Query 3: bio_profil
  // ─────────────────────────────────────────────────────
  Future<void> fetchProfile(String mentorId) async {
    isLoading    = true;
    errorMessage = null;

    try {
      // ── Query 1: data profil mentor ─────────────────
      final response = await _supabase
          .from('appuser')
          .select('''
            id,
            nama_lengkap,
            bio_profil!inner(
              nama_lengkap,
              foto_url,
              bio,
              alamat,
              nomor_hp,
              categories(category_name),
              universities(university_name)
            ),
            service_rates(price_per_session),
            mentor_schedules(
              id,
              available_date,
              start_time,
              is_booked
            )
          ''')
          .eq('id', mentorId)
          .single();

      final profileJson = response as Map<String, dynamic>;

      // ── Query 2: reviews + nama client ──────────────
      final reviewsRaw = await _supabase
          .from('reviews')
          .select('''
            id,
            rating,
            review_text,
            created_at,
            reviewer:client_id(
              id,
              nama_lengkap,
              email
            )
          ''')
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);

      final reviewsList =
          List<Map<String, dynamic>>.from(reviewsRaw as List);

          final totalReviews = reviewsList.length;

          double? avgRating;

          if (reviewsList.isNotEmpty) {
            final totalRating = reviewsList.fold<int>(
              0,
              (sum, item) => sum + ((item['rating'] as num?)?.toInt() ?? 0),
            );

            avgRating = totalRating / totalReviews;
          }

      // ── Query 3: foto reviewer via email (batch) ────
      final emails = <String>{};
      for (final r in reviewsList) {
        final reviewer = r['reviewer'] as Map<String, dynamic>?;
        final email    = reviewer?['email'] as String?;
        if (email != null && email.isNotEmpty) emails.add(email);
      }

      final Map<String, String?> fotoMap = {};
      if (emails.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('email, foto_url')
            .inFilter('email', emails.toList());

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          final email = bio['email'] as String?;
          if (email != null) fotoMap[email] = bio['foto_url'] as String?;
        }
      }

      // ── Enrich reviews dengan foto ──────────────────
      final enrichedReviews = reviewsList.map((r) {
        final reviewer = r['reviewer'] as Map<String, dynamic>?;
        final email    = reviewer?['email'] as String?;
        return {
          ...r,
          '_bio': {'foto_url': email != null ? fotoMap[email] : null},
        };
      }).toList();

      // ── Gabung ke profileJson ───────────────────────
      final merged = {
        ...profileJson,
        'reviews': enrichedReviews,
        'avg_rating': avgRating,
        'total_reviews': totalReviews,
      };

      profileData = MentorProfileModel.fromJson(merged);
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      isLoading = false;
    }
  }
}