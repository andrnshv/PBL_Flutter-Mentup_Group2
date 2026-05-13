import '../../models/clien/profile_model.dart';
import '../../services/supabase_service.dart';

class ProfileController {

  Future<ProfileModel?> loadProfileData() async {
    try {
      final user = SupabaseService.currentUser;

      if (user == null) return null;

      /// APPUSER
      final appuserData = await SupabaseService.db
          .from('appuser')
          .select('nama_lengkap, username, email')
          .eq('id', user.id)
          .single();

      /// BIO PROFILE
      final bioData = await SupabaseService.db
          .from('bio_profil')
          .select('foto_url, bio')
          .eq('email', appuserData['email'] ?? user.email ?? '')
          .maybeSingle();

      return ProfileModel.fromMap(
        appuser: appuserData,
        bio: bioData,
      );

    } catch (e) {
      print('Load profile error: $e');
      return null;
    }
  }
}