import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor/client_review_model.dart';

class ClientReviewController {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ClientReviewModel> allReviews = [];
  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  int selectedStarFilter = 0; // 0 = All
  bool isNewestFirst = true;

  Future<void> fetchReviews() async {
    final mentorId = _supabase.auth.currentUser?.id;
    if (mentorId == null) {
      errorMessage = 'User not authenticated.';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      // Query 1: reviews + nama client
      final res = await _supabase.from('reviews').select('''
            id,
            rating,
            review_text,
            created_at,
            appuser:client_id (
              id,
              nama_lengkap,
              email
            )
          ''').eq('mentor_id', mentorId).order('created_at', ascending: false);

      final List<Map<String, dynamic>> raw =
          List<Map<String, dynamic>>.from(res as List);

      if (raw.isEmpty) {
        allReviews = [];
        return;
      }

      // Query 2: bio_profil via email → foto + kategori
      final emails = raw
          .map((r) =>
              (r['appuser'] as Map<String, dynamic>?)?['email'] as String?)
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

      allReviews = raw.map((r) {
        final client = r['appuser'] as Map<String, dynamic>?;
        final email = client?['email'] as String?;
        final bio = email != null ? bioMap[email] : null;

        final rawCat = bio?['categories'];
        String? categoryName;
        if (rawCat is Map) {
          categoryName = rawCat['category_name'] as String?;
        } else if (rawCat is List && rawCat.isNotEmpty) {
          categoryName = (rawCat.first as Map)['category_name'] as String?;
        }

        return ClientReviewModel.fromJson({
          ...r,
          'foto_url': bio?['foto_url'],
          'category_name': categoryName,
        });
      }).toList();
    } on PostgrestException catch (e) {
      errorMessage = e.message;
      allReviews = [];
    } catch (e) {
      errorMessage = 'Gagal memuat ulasan: $e';
      allReviews = [];
    } finally {
      isLoading = false;
    }
  }

  // Filter + sort
  List<ClientReviewModel> get filteredReviews {
    var result = allReviews.where((r) {
      final matchSearch = searchQuery.isEmpty ||
          r.clientName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchStar =
          selectedStarFilter == 0 || r.rating == selectedStarFilter;
      return matchSearch && matchStar;
    }).toList();

    result.sort((a, b) => isNewestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));

    return result;
  }
}
