import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/client/security_model.dart';
import '../../services/supabase_service.dart';

class SecurityController {
  Future<SecurityModel> getSecurityData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    final data = await SupabaseService.db
        .from('appuser')
        .select('email')
        .eq('id', user.id)
        .single();

    return SecurityModel.fromJson(data);
  }

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    await SupabaseService.db
        .from('appuser')
        .delete()
        .eq('id', user.id);

    await SupabaseService.db
        .from('bio_profil')
        .delete()
        .eq('email', user.email ?? '');
  }
}