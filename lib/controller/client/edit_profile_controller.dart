import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/client/edit_profile_model.dart';

class EditProfileController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // State untuk foto
  File? selectedImageFile;
  String? currentFotoUrl;
  String? currentEmail;

  // ─────────────────────────────────────────────────────
  // GET PROFILE
  // ─────────────────────────────────────────────────────
  Future<EditProfileModel?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      currentEmail = user.email;

      final appuser = await _supabase
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', user.id)
          .single();

      final bioProfile = await _supabase
          .from('bio_profil')
          .select('bio, foto_url, alamat')
          .eq('email', appuser['email'])
          .maybeSingle();

      currentFotoUrl = bioProfile?['foto_url'];

      return EditProfileModel(
        namaLengkap: appuser['nama_lengkap'] ?? '',
        email:       appuser['email'] ?? '',
        alamat:      bioProfile?['alamat'] ?? '',
        bio:         bioProfile?['bio'] ?? '',
        fotoUrl:     currentFotoUrl,
      );
    } catch (e) {
      print("GET PROFILE ERROR: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // PICK IMAGE
  // ─────────────────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImageFile = File(pickedFile.path);
      }
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
    }
  }

  // ─────────────────────────────────────────────────────
  // UPLOAD IMAGE
  // ─────────────────────────────────────────────────────
  Future<String?> uploadImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      const bucketName = 'foto-profil';
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${user.id}/$fileName';

      final bytes = await imageFile.readAsBytes();

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl =
          _supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print("UPLOAD IMAGE ERROR: $e");
      return null;
    }
  }

  // ─────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String namaLengkap,
    required String email,
    required String alamat,
    required String bio,
    String? fotoUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // UPDATE appuser
      await _supabase
          .from('appuser')
          .update({'nama_lengkap': namaLengkap})
          .eq('id', user.id);

      // UPSERT bio_profil
      await _supabase
          .from('bio_profil')
          .upsert(
            {
              'email':         email,
              'nama_lengkap':  namaLengkap,
              'alamat':        alamat,
              'bio':           bio,
              'foto_url':      fotoUrl,
            },
            onConflict: 'email',
          );

      // Update local state
      currentFotoUrl = fotoUrl;
      selectedImageFile = null;

      return true;
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");
      return false;
    }
  }
}