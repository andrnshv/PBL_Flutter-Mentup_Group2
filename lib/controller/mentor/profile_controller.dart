import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/mentor/profile_model.dart';

class MentorProfileController {

  Future<MentorProfileModel?> getProfile() async {
    try {

      final user = SupabaseService.currentUser;

      if (user == null) {
        debugPrint('USER NULL');
        return null;
      }

      debugPrint('AUTH USER: ${user.email}');

      // APPUSER
      final appuser = await SupabaseService.db
          .from('appuser')
          .select('id, nama_lengkap, username')
          .eq('email', user.email ?? '')
          .maybeSingle();

      debugPrint('APPUSER DATA: $appuser');

      if (appuser == null) {
        debugPrint('APPUSER NOT FOUND');
        return null;
      }

      // BIO PROFIL
      final bio = await SupabaseService.db
          .from('bio_profil')
          .select('''
            bio,
            foto_url,
            categories(category_name),
            universities(university_name)
          ''')
          .eq('user_id', appuser['id'])
          .maybeSingle();

      debugPrint('BIO DATA: $bio');

      return MentorProfileModel.fromMap(
        appuser,
        bio,
      );

    } catch (e) {

      debugPrint('GET MENTOR PROFILE ERROR: $e');

      return null;
    }
  }
}