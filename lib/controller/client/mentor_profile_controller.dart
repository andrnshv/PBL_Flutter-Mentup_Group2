import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/mentor_profile_model.dart';

class MentorProfileController {
  final SupabaseClient _supabase = Supabase.instance.client;

  MentorProfileModel? profileData;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch detail lengkap satu mentor berdasarkan [mentorId] (= appuser.id).
  /// Semua data diambil sekali lewat Supabase nested select.
  Future<void> fetchProfile(String mentorId) async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await _supabase.from('appuser').select('''
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
          ''').eq('id', mentorId).single();

      profileData =
          MentorProfileModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      isLoading = false;
    }
  }
}
