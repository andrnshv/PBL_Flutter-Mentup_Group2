import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/clien/edit_profile_model.dart';
import '../../services/supabase_service.dart';

class EditProfileController {

  Future<EditProfileModel?> getProfile()
  async {

    try {

      final user =
          SupabaseService.currentUser;

      if (user == null) return null;

      final appuser =
          await SupabaseService.db
              .from('appuser')
              .select(
                'nama_lengkap, email',
              )
              .eq('id', user.id)
              .single();

      final bioProfile =
          await SupabaseService.db
              .from('bio_profil')
              .select(
                'bio, foto_url',
              )
              .eq(
                'email',
                appuser['email'],
              )
              .maybeSingle();

      return EditProfileModel(
        namaLengkap:
            appuser['nama_lengkap'] ?? '',

        email:
            appuser['email'] ?? '',

        bio:
            bioProfile?['bio'] ??
                '',

        fotoUrl:
            bioProfile?['foto_url'],
      );

    } catch (e) {

      return null;
    }
  }

  Future<String?> uploadImage(
    File imageFile,
  ) async {

    try {

      final user =
          SupabaseService.currentUser;

      if (user == null) return null;

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final path =
          '${user.id}/$fileName';

      await SupabaseService.storage
          .from('profile')
          .upload(
            path,
            imageFile,
          );

      final imageUrl =
          SupabaseService.storage
              .from('profile')
              .getPublicUrl(path);

      return imageUrl;

    } catch (e) {

      return null;
    }
  }

  Future<bool> updateProfile({
    required String namaLengkap,
    required String email,
    required String bio,
    String? fotoUrl,
  }) async {

    try {

      final user =
          SupabaseService.currentUser;

      if (user == null) return false;

      await SupabaseService.db
          .from('appuser')
          .update({
            'nama_lengkap':
                namaLengkap,
            'email': email,
          })
          .eq('id', user.id);

      await SupabaseService.db
          .from('bio_profil')
          .upsert({
            'email': email,
            'nama_lengkap':
                namaLengkap,
            'bio': bio,
            'foto_url': fotoUrl,
          });

      return true;

    } catch (e) {

      return false;
    }
  }
}