import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/edit_profile_model.dart';
import '../../services/supabase_service.dart';

class EditProfileController {

  Future<EditProfileModel?> getProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      final appuser = await SupabaseService.client
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', user.id)
          .single();

      final bioProfile = await SupabaseService.client
          .from('bio_profil')
          .select('bio, foto_url, alamat')
          .eq('email', appuser['email'])
          .maybeSingle();

      return EditProfileModel(
        namaLengkap: appuser['nama_lengkap'] ?? '',
        email: appuser['email'] ?? '',
        alamat: bioProfile?['alamat'] ?? '',
        bio: bioProfile?['bio'] ?? '',
        fotoUrl: bioProfile?['foto_url'],
      );

    } catch (e) {
      print("GET PROFILE ERROR: $e");
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path = '${user.id}/$fileName';

      await SupabaseService.storage
          .from('foto-profil')
          .upload(path, imageFile);

      return SupabaseService.storage
          .from('foto-profil')
          .getPublicUrl(path);

    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }

  Future<bool> updateProfile({
    required String namaLengkap,
    required String email,
    required String alamat,
    required String bio,
    String? fotoUrl,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      // 1. update appuser
      await SupabaseService.client
          .from('appuser')
          .update({
            'nama_lengkap': namaLengkap,
          })
          .eq('id', user.id);

      // 2. upsert bio_profil (WAJIB onConflict)
      await SupabaseService.client
          .from('bio_profil')
          .upsert({
            'email': email,
            'nama_lengkap': namaLengkap,
            'alamat': alamat,
            'bio': bio,
            'foto_url': fotoUrl,
          }, onConflict: 'email');

      return true;

    } catch (e) {
      print("UPDATE ERROR DETAIL: $e");
      return false;
    }
  }
}