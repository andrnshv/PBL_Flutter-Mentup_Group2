import '../../models/client/profile_model.dart';
import '../../services/supabase_service.dart';

class ProfileController {
  Future<ProfileModel?> getProfile() async {
    try {
      final user = SupabaseService.currentUser;

      if (user == null) return null;

      final appuserData = await SupabaseService.db
          .from('appuser')
          .select()
          .eq('id', user.id)
          .single();

      final bioData = await SupabaseService.db
          .from('bio_profil')
          .select()
          .eq('email', user.email ?? '')
          .maybeSingle();

      return ProfileModel(
        namaLengkap: appuserData['nama_lengkap'] ?? '',
        username: appuserData['username'] ?? '',
        bio: bioData?['bio'] ?? '',
        fotoUrl: bioData?['foto_url'],
      );
    } catch (e) {
      return null;
    }
  }
}