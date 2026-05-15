import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/supabase_service.dart';

class EditProfileController {
  // ================= TEXT =================
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final keahlianController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final categoryController = TextEditingController();
  final universityController = TextEditingController();

  // ================= DROPDOWN =================
  List<String> categories = [];
  List<String> universities = [];

  String? selectedCategory;
  String? selectedUniversity;

  // ================= FILE =================
  Uint8List? profileImageBytes;
  File? profileImageFile;

  Uint8List? cvDocumentBytes;
  File? cvDocumentFile;

  String? cvFileName;

  String? currentFotoUrl;
  String? currentCvUrl;

  final ImagePicker _picker = ImagePicker();

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    final user = SupabaseService.currentUser;

    debugPrint("🟡 LOAD PROFILE START");

    if (user == null) {
      debugPrint("❌ USER NULL");
      return;
    }

    debugPrint("🟢 USER ID => ${user.id}");

    final appuser = await SupabaseService.db
        .from('appuser')
        .select()
        .eq('id', user.id)
        .single();

    debugPrint("🟢 APPUSER => $appuser");

    final bio = await SupabaseService.db
        .from('bio_profil')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    debugPrint("🟢 BIO => $bio");

    final cv = await SupabaseService.db
        .from('mentor_cv')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    debugPrint("🟢 CV RAW => $cv");

    nameController.text = appuser['nama_lengkap'] ?? '';
    usernameController.text = appuser['username'] ?? '';

    phoneController.text = bio?['nomor_hp'] ?? '';
    addressController.text = bio?['alamat'] ?? '';
    bioController.text = bio?['bio'] ?? '';

    currentFotoUrl = bio?['foto_url'];
    currentCvUrl = cv?['cv_url'];

    debugPrint("🟢 FOTO URL => $currentFotoUrl");
    debugPrint("🟢 CV URL => $currentCvUrl");

    final keahlian = bio?['keahlian'] ?? '';
    final universitas = bio?['universitas'] ?? '';

    selectedCategory = keahlian.isNotEmpty ? keahlian : null;
    selectedUniversity = universitas.isNotEmpty ? universitas : null;

    debugPrint("🟡 LOAD PROFILE DONE");
  }

  // ================= SAVE PROFILE =================
  Future<bool> saveProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      await SupabaseService.db.from('bio_profil').upsert({
        'user_id': user.id,
        'alamat': addressController.text.trim(),
        'bio': bioController.text.trim(),
        'foto_url': currentFotoUrl,
      }, onConflict: 'id');

      return true;
    } catch (e) {
      debugPrint("SAVE ERROR => $e");
      return false;
    }
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      profileImageBytes = await picked.readAsBytes();
      if (!kIsWeb) profileImageFile = File(picked.path);

      debugPrint("📸 IMAGE PICKED => ${picked.path}");
    }
  }

  // ================= PICK CV =================
  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      cvFileName = result.files.single.name;
      cvDocumentBytes = result.files.single.bytes;

      if (!kIsWeb && result.files.single.path != null) {
        cvDocumentFile = File(result.files.single.path!);
      }

      debugPrint("📄 CV PICKED => $cvFileName");
    }
  }

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    keahlianController.dispose();
    addressController.dispose();
    bioController.dispose();
    categoryController.dispose();
    universityController.dispose();
  }
}