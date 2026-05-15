import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/mentor/profile_model.dart';

class MentorProfileController {

  Future<MentorProfileModel?> getProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      final appuser = await SupabaseService.db
          .from('appuser')
          .select('nama_lengkap, username')
          .eq('id', user.id)
          .single();

      debugPrint('APPUSER: $appuser');

      final bio = await SupabaseService.db
          .from('bio_profil')
          .select('bio, keahlian, universitas, foto_url')
          .eq('user_id', user.id)  // ← pakai user_id bukan email
          .maybeSingle();

      debugPrint('BIO: $bio');

      return MentorProfileModel.fromMap(appuser, bio);

    } catch (e) {
      debugPrint('GET MENTOR PROFILE ERROR: $e');
      return null;
    }
  }
}