import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/auth/register_model.dart';
import '../../services/supabase_service.dart';

class RegisterController {

  Future<String?> register(RegisterModel model) async {
    try {

      /// AUTH SIGNUP
      final response = await SupabaseService.auth.signUp(
        email: model.email,
        password: model.password,

        data: {
          'nama_lengkap': model.namaLengkap,
          'role': model.role,
        },
      );

      final user = response.user;

      if (user == null) {
        return "Gagal mendapatkan data user.";
      }

      /// APPUSER
      await SupabaseService.db
          .from('appuser')
          .upsert({
        'id': user.id,
        'nama_lengkap': model.namaLengkap,
        'username': model.username,
        'email': model.email,
        'role': model.role,
      }, onConflict: 'id');

      /// BIO PROFILE
      await SupabaseService.db
          .from('bio_profil')
          .upsert({
        'email': model.email,
        'nama_lengkap': model.namaLengkap,
      }, onConflict: 'email');

      return null;

    } on AuthException catch (e) {

      if (e.message
          .toLowerCase()
          .contains("already registered")) {

        return "EMAIL_ALREADY_REGISTERED";
      }

      return e.message;

    } on PostgrestException catch (e) {

      return "Database: ${e.message}";

    } catch (e) {

      return "Terjadi kesalahan: $e";
    }
  }
}