import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/auth/cv_upload_model.dart';

class CvUploadController {

  /// CEK APAKAH USER SUDAH PERNAH SUBMIT CV
  Future<bool> checkCvStatus(String userId) async {
    try {
      final data = await SupabaseService.db
          .from('mentor_cv')
          .select('status')
          .eq('user_id', userId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      print("CHECK CV ERROR: $e");
      return false;
    }
  }

  /// AMBIL DATA USER (nama + email)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final data = await SupabaseService.db
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', userId)
          .single();

      return data;
    } catch (e) {
      print("GET USER ERROR: $e");
      return null;
    }
  }

  /// UPLOAD FILE CV (WEB + MOBILE SUPPORT)
  Future<String?> uploadCvFile({
    required String userId,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      const bucket = 'mentor_cv';

      final fileName =
          'cv_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final filePath = '$userId/$fileName';

      if (bytes != null) {
        await SupabaseService.storage
            .from(bucket)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else if (file != null) {
        await SupabaseService.storage
            .from(bucket)
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        return null;
      }

      return SupabaseService.storage
          .from(bucket)
          .getPublicUrl(filePath);

    } catch (e) {
      print("UPLOAD CV ERROR: $e");
      return null;
    }
  }

  /// SIMPAN KE TABEL mentor_cv
  Future<bool> submitCv({
    required String userId,
    required String cvUrl,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await SupabaseService.db.from('mentor_cv').upsert({
        'user_id': userId,
        'nama_lengkap': userData['nama_lengkap'],
        'email': userData['email'],
        'cv_url': cvUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      return true;
    } catch (e) {
      print("SUBMIT CV ERROR: $e");
      return false;
    }
  }
}