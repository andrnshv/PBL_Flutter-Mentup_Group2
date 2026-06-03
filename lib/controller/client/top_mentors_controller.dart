import 'package:supabase_flutter/supabase_flutter.dart';

// ================================================================
//  TOP MENTORS CONTROLLER — MentUp
//  File: lib/controller/client/top_mentors_controller.dart
//
//  Menampilkan mentor PERINGKAT berdasarkan rating dari klien.
//  Hanya mentor yang sudah pernah dirating yang muncul, diurutkan
//  dari rating rata-rata TERTINGGI.
//
//  Sumber: tabel `reviews` (rating, mentor_id) + bio_profil (nama,
//  foto, kategori).
// ================================================================

class TopMentorModel {
  final String mentorId;
  final String name;
  final String category;
  final String? fotoUrl;
  final double avgRating;
  final int totalReviews;

  const TopMentorModel({
    required this.mentorId,
    required this.name,
    required this.category,
    required this.avgRating,
    required this.totalReviews,
    this.fotoUrl,
  });
}

class TopMentorsController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<TopMentorModel> topMentors = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchTopMentors() async {
    isLoading = true;
    errorMessage = null;

    try {
      // 1. Ambil semua review (rating + mentor_id)
      final reviews =
          await _supabase.from('reviews').select('mentor_id, rating');

      final reviewList = List<Map<String, dynamic>>.from(reviews);

      if (reviewList.isEmpty) {
        topMentors = [];
        isLoading = false;
        return;
      }

      // 2. Hitung rata-rata rating + jumlah review per mentor
      final Map<String, List<double>> ratingsByMentor = {};
      for (final r in reviewList) {
        final mentorId = r['mentor_id'] as String?;
        final rating = (r['rating'] as num?)?.toDouble();
        if (mentorId == null || rating == null) continue;
        ratingsByMentor.putIfAbsent(mentorId, () => []).add(rating);
      }

      if (ratingsByMentor.isEmpty) {
        topMentors = [];
        isLoading = false;
        return;
      }

      // 3. Ambil info mentor (nama, foto, kategori) dari bio_profil
      final mentorIds = ratingsByMentor.keys.toList();
      final bios = await _supabase
          .from('bio_profil')
          .select('user_id, nama_lengkap, foto_url, categories(category_name)')
          .inFilter('user_id', mentorIds);

      final Map<String, Map<String, dynamic>> bioMap = {};
      for (final bio in List<Map<String, dynamic>>.from(bios)) {
        bioMap[bio['user_id'] as String] = bio;
      }

      // 4. Susun TopMentorModel
      final result = <TopMentorModel>[];
      ratingsByMentor.forEach((mentorId, ratings) {
        final avg = ratings.reduce((a, b) => a + b) / ratings.length;
        final bio = bioMap[mentorId];

        result.add(TopMentorModel(
          mentorId: mentorId,
          name: bio?['nama_lengkap'] as String? ?? 'Mentor',
          category: (bio?['categories']
                  as Map<String, dynamic>?)?['category_name'] as String? ??
              'Mentor',
          fotoUrl: bio?['foto_url'] as String?,
          avgRating: double.parse(avg.toStringAsFixed(1)),
          totalReviews: ratings.length,
        ));
      });

      // 5. Urutkan rating tertinggi dulu (peringkat)
      result.sort((a, b) => b.avgRating.compareTo(a.avgRating));

      topMentors = result;
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Gagal memuat top mentor: $e';
    } finally {
      isLoading = false;
    }
  }
}
