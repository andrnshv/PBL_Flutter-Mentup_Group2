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

  // =========================
  // UPLOAD IMAGE
  // =========================
  Future<String?> uploadImage(File imageFile) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      const bucketName = 'foto-profil';

      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final filePath = '${user.id}/$fileName';

      final bytes = await imageFile.readAsBytes();

      await SupabaseService.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return SupabaseService.storage
          .from(bucketName)
          .getPublicUrl(filePath);

    } catch (e) {
      print("UPLOAD IMAGE ERROR: $e");
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

      // UPDATE appuser
      await SupabaseService.client
          .from('appuser')
          .update({
            'nama_lengkap': namaLengkap,
          })
          .eq('id', user.id);

      // UPSERT bio_profil
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
      print("UPDATE PROFILE ERROR: $e");
      return false;
    }
  }
}