import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/clien/profile_model.dart';
import '../../services/supabase_service.dart';

class ProfileController {
  Future<ProfileModel?> loadProfileData() async {
    try {
      final user = SupabaseService.currentUser;

      if (user == null) return null;

      final appuserData = await SupabaseService.db
          .from('appuser')
          .select('nama_lengkap, username, email')
          .eq('id', user.id)
          .single();

      final bioData = await SupabaseService.db
          .from('bio_profil')
          .select('foto_url, bio')
          .eq(
            'email',
            appuserData['email'] ?? user.email ?? '',
          )
          .maybeSingle();

      return ProfileModel(
        namaLengkap:
            appuserData['nama_lengkap'] ?? '',
        username:
            appuserData['username'] ?? '',
        bio: bioData?['bio'] ?? 'No bio yet.',
        fotoUrl: bioData?['foto_url'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}