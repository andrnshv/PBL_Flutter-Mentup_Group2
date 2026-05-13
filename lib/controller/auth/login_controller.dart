import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/auth/login_model.dart';
import '../../services/supabase_service.dart';

class LoginController {

  bool isEmail(String input) {
    return input.contains('@');
  }

  Future<String?> resolveEmail(
    String identifier,
  ) async {

    if (isEmail(identifier)) {
      return identifier;
    }

    final result = await SupabaseService.db
        .from('appuser')
        .select('email')
        .eq('username', identifier)
        .maybeSingle();

    return result?['email'] as String?;
  }

  Future<String?> login(
    LoginModel model,
  ) async {

    try {

      /// RESOLVE EMAIL
      final email =
          await resolveEmail(model.identifier);

      if (email == null) {
        return 'Username tidak ditemukan.';
      }

      /// LOGIN
      final response =
          await SupabaseService.auth
              .signInWithPassword(
        email: email,
        password: model.password,
      );

      if (response.user == null) {
        return 'Login gagal.';
      }

      /// REMEMBER ME
      final prefs =
          await SharedPreferences.getInstance();

      if (model.rememberMe) {

        await prefs.setBool(
          'remember_me',
          true,
        );

        await prefs.setString(
          'saved_identifier',
          model.identifier,
        );

      } else {

        await prefs.remove('remember_me');

        await prefs.remove(
          'saved_identifier',
        );
      }

      return null;

    } on AuthException catch (e) {

      return e.message;

    } catch (e) {

      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> getUserRole(
    String userId,
  ) async {

    final userData =
        await SupabaseService.db
            .from('appuser')
            .select('role')
            .eq('id', userId)
            .single();

    return userData['role'];
  }

  Future<String?> getMentorCvStatus(
    String userId,
  ) async {

    final cvData =
        await SupabaseService.db
            .from('mentor_cv')
            .select('status')
            .eq('user_id', userId)
            .maybeSingle();

    if (cvData == null) {
      return null;
    }

    return cvData['status'];
  }

  Future<String?> getSavedIdentifier()
  async {

    final prefs =
        await SharedPreferences.getInstance();

    final rememberMe =
        prefs.getBool('remember_me');

    if (rememberMe == true) {

      return prefs.getString(
        'saved_identifier',
      );
    }

    return null;
  }
}