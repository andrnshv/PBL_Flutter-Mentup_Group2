import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/supabase_service.dart';

class EditProfileController {

  // ================= TEXT =================

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();

  final categoryController = TextEditingController();
  final universityController = TextEditingController();

  // ================= DROPDOWN =================

  List<String> categories = [];
  List<String> universities = [];

  Map<String, String> categoryMap = {};
  Map<String, String> universityMap = {};

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

  String? appUserId;

  // =========================================================
  // LOAD PROFILE
  // =========================================================

Future<void> loadProfile() async {
  final authUser = SupabaseService.currentUser;
  if (authUser == null) {
    debugPrint("AUTH USER NULL");
    return;
  }

  // =========================================================
  // STEP 1: Load dropdown DULU sebelum apapun
  // =========================================================
  await loadDropdownData(); // <-- PINDAH KE SINI, PERTAMA

  // =========================================================
  // APPUSER
  // =========================================================
  try {
    final appuser = await SupabaseService.db
        .from('appuser')
        .select()
        .eq('email', authUser.email ?? '')
        .single();

    appUserId = appuser['id'];
    nameController.text = appuser['nama_lengkap'] ?? '';
    usernameController.text = appuser['username'] ?? '';
    debugPrint("APPUSER SUCCESS => id: $appUserId");
  } catch (e) {
    debugPrint("APPUSER ERROR => $e");
  }

  // =========================================================
  // BIO PROFIL — JANGAN early return kalau appUserId null
  // =========================================================
  if (appUserId == null) {
    debugPrint("APP USER ID NULL, skip bio & cv");
    return; // <-- dipindah ke sini, setelah appuser load
  }

  try {
    final bio = await SupabaseService.db
        .from('bio_profil')
        .select()
        .eq('user_id', appUserId!)
        .maybeSingle();

    debugPrint("BIO => $bio");

    if (bio != null) {
      phoneController.text   = bio['nomor_hp'] ?? '';
      addressController.text = bio['alamat']   ?? '';
      bioController.text     = bio['bio']      ?? '';
      currentFotoUrl         = bio['foto_url'];

      // ================= CATEGORY FK =================
      final categoryId = bio['category_id'];
      if (categoryId != null) {
        try {
          final category = await SupabaseService.db
              .from('categories')
              .select('category_name')
              .eq('id', categoryId)
              .maybeSingle();

          final name = category?['category_name']?.toString();
          // Pastikan ada di list sebelum di-set
          if (name != null && categories.contains(name)) {
            selectedCategory = name;
          }
        } catch (e) {
          debugPrint("CATEGORY FK ERROR => $e");
        }
      }

      // ================= UNIVERSITY FK =================
      final universityId = bio['university_id'];
      if (universityId != null) {
        try {
          final university = await SupabaseService.db
              .from('universities')
              .select('university_name')
              .eq('id', universityId)
              .maybeSingle();

          final name = university?['university_name']?.toString();
          // Pastikan ada di list sebelum di-set
          if (name != null && universities.contains(name)) {
            selectedUniversity = name;
          }
        } catch (e) {
          debugPrint("UNIVERSITY FK ERROR => $e");
        }
      }
    }
    debugPrint("BIO SUCCESS");
  } catch (e) {
    debugPrint("BIO ERROR => $e");
  }

  // =========================================================
  // CV
  // =========================================================
  try {
    final cv = await SupabaseService.db
        .from('mentor_cv')
        .select()
        .eq('user_id', appUserId!)
        .maybeSingle();

    debugPrint("CV => $cv");
    currentCvUrl = cv?['cv_url'];
    debugPrint("CV SUCCESS");
  } catch (e) {
    debugPrint("CV ERROR => $e");
  }

  debugPrint("SELECTED CATEGORY   => $selectedCategory");
  debugPrint("SELECTED UNIVERSITY => $selectedUniversity");
  debugPrint("CATEGORY COUNT      => ${categories.length}");
  debugPrint("UNIVERSITY COUNT    => ${universities.length}");
  debugPrint("LOAD PROFILE DONE");
}

  // =========================================================
  // SAVE BIO DATA
  // =========================================================

    Future<bool> saveBioData() async {
    try {
      if (appUserId == null) return false;

      final authUser = SupabaseService.currentUser;
      final email = authUser?.email ?? '';

      // Upload foto dulu kalau ada perubahan
      if (profileImageBytes != null) {
        final uploadedUrl = await uploadProfileImage();
        if (uploadedUrl != null) {
          currentFotoUrl = uploadedUrl; // update url lokal
        }
      }

      final existing = await SupabaseService.db
          .from('bio_profil')
          .select()
          .eq('user_id', appUserId!)
          .maybeSingle();

      final data = {
        'user_id'  : appUserId,
        'email'    : email,
        'nomor_hp' : phoneController.text.trim(),
        'alamat'   : addressController.text.trim(),
        'bio'      : bioController.text.trim(),
        'foto_url' : currentFotoUrl,  // url hasil upload
      };

      if (existing == null) {
        await SupabaseService.db.from('bio_profil').insert(data);
        debugPrint("BIO INSERTED");
      } else {
        await SupabaseService.db
            .from('bio_profil')
            .update(data)
            .eq('user_id', appUserId!);
        debugPrint("BIO UPDATED");
      }

      return true;
    } catch (e) {
      debugPrint("SAVE BIO ERROR => $e");
      return false;
    }
  }

  // =========================================================
  // LOAD Profile Image
  // =========================================================
    Future<String?> uploadProfileImage() async {
    debugPrint("=== UPLOAD IMAGE START ===");
    debugPrint("profileImageBytes: ${profileImageBytes?.length} bytes");
    debugPrint("appUserId: $appUserId");

    try {
      if (profileImageBytes == null) {
        debugPrint("NO IMAGE BYTES, return currentFotoUrl: $currentFotoUrl");
        return currentFotoUrl;
      }

      final fileName = 'avatar_${appUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$appUserId/$fileName';
      debugPrint("FILE NAME => $fileName");
      debugPrint("FILE PATH => $filePath");

      await SupabaseService.db.storage
          .from('foto-profil')
          .uploadBinary(
            filePath,
            profileImageBytes!,
          );

      debugPrint("UPLOAD BINARY SUCCESS");

      final publicUrl = SupabaseService.db.storage
          .from('foto-profil')
          .getPublicUrl(filePath);

      debugPrint("PUBLIC URL => $publicUrl");
      debugPrint("=== UPLOAD IMAGE DONE ===");

      return publicUrl;

    } catch (e) {
      debugPrint("=== UPLOAD IMAGE ERROR ===");
      debugPrint("ERROR => $e");
      return null;
    }
  }

  // ================= LOAD DROPDOWN DATA =================
Future<void> loadDropdownData() async {
  try {
    // ================= CATEGORY =================
    final categoryResult = await SupabaseService.db
        .from('categories')
        .select();

    categories.clear();
    categoryMap.clear();

    for (final item in categoryResult) {
      final map  = item as Map<String, dynamic>;
      final name = map['category_name']?.toString() ?? '';
      final id = map['id'].toString();
      if (name.isNotEmpty) {
        categories.add(name);
        categoryMap[name] = id;
      }
    }

    if (!categories.contains('Lainnya')) categories.add('Lainnya'); // <-- guard dobel

    // ================= UNIVERSITY =================
    final universityResult = await SupabaseService.db
        .from('universities')
        .select();

    debugPrint("UNIVERSITY RAW => $universityResult"); // <-- tambah ini
    debugPrint("UNIVERSITY LENGTH => ${universityResult.length}");

    universities.clear();
    universityMap.clear();

    for (final item in universityResult) {
      final map  = item as Map<String, dynamic>;
      final name = map['university_name']?.toString() ?? '';
      final id = map['id'].toString();
      if (name.isNotEmpty) {
        universities.add(name);
        universityMap[name] = id;
      }
    }

    if (!universities.contains('Lainnya')) universities.add('Lainnya'); // <-- guard dobel

    debugPrint("CATEGORY   => $categories");
    debugPrint("UNIVERSITY => $universities");
  } catch (e) {
    debugPrint("LOAD DROPDOWN ERROR => $e");
  }
}

  // =========================================================
  // SAVE CATEGORY
  // =========================================================

  Future<bool> saveCategory() async {
  try {
    if (appUserId == null) return false;

    final email = SupabaseService.currentUser?.email ?? ''; // <-- tambah

    String? categoryId;

    if (selectedCategory == 'Lainnya') {
      final customName = categoryController.text.trim();
      if (customName.isEmpty) return false;

      final existing = await SupabaseService.db
          .from('categories')
          .select()
          .eq('category_name', customName)
          .maybeSingle();

      if (existing != null) {
        categoryId = existing['id'].toString();
      } else {
        final inserted = await SupabaseService.db
            .from('categories')
            .insert({'category_name': customName})
            .select()
            .single();
        categoryId = inserted['id'].toString();
      }

      categories.insert(categories.length - 1, customName);
      categoryMap[customName] = categoryId!;
      selectedCategory = customName;
      categoryController.clear();

    } else {
      categoryId = categoryMap[selectedCategory];
    }

    if (categoryId == null) return false;

    // ================= UPDATE BIO =================
    final existingBio = await SupabaseService.db
        .from('bio_profil')
        .select()
        .eq('user_id', appUserId!)
        .maybeSingle();

    if (existingBio == null) {
      await SupabaseService.db.from('bio_profil').insert({
        'user_id'     : appUserId,
        'email'       : email,       // <-- tambah
        'category_id' : categoryId,
      });
    } else {
      await SupabaseService.db
          .from('bio_profil')
          .update({'category_id': categoryId})
          .eq('user_id', appUserId!);
    }

    // ================= MENTOR CATEGORIES =================
    final existingRelation = await SupabaseService.db
        .from('mentor_categories')
        .select()
        .eq('mentor_id', appUserId!)
        .eq('category_id', categoryId)
        .maybeSingle();

    if (existingRelation == null) {
      await SupabaseService.db.from('mentor_categories').insert({
        'mentor_id'   : appUserId,
        'category_id' : categoryId,
      });
    }

    debugPrint("SAVE CATEGORY SUCCESS => $categoryId");
    return true;
  } catch (e) {
    debugPrint("SAVE CATEGORY ERROR => $e");
    return false;
  }
}

  // =========================================================
  // SAVE UNIVERSITY
  // =========================================================

    Future<bool> saveUniversity() async {
  try {
    if (appUserId == null) return false;

    final email = SupabaseService.currentUser?.email ?? ''; // <-- tambah

    String? universityId;

    if (selectedUniversity == 'Lainnya') {
      final customName = universityController.text.trim();
      if (customName.isEmpty) return false;

      final existing = await SupabaseService.db
          .from('universities')
          .select()
          .eq('university_name', customName)
          .maybeSingle();

      if (existing != null) {
        universityId = existing['id'].toString();
      } else {
        final inserted = await SupabaseService.db
            .from('universities')
            .insert({'university_name': customName})
            .select()
            .single();
        universityId = inserted['id'].toString();
      }

      universities.insert(universities.length - 1, customName);
      universityMap[customName] = universityId!;
      selectedUniversity = customName;
      universityController.clear();

    } else {
      universityId = universityMap[selectedUniversity];
    }

    if (universityId == null) return false;

    // ================= UPDATE BIO =================
    final existingBio = await SupabaseService.db
        .from('bio_profil')
        .select()
        .eq('user_id', appUserId!)
        .maybeSingle();

    if (existingBio == null) {
      await SupabaseService.db.from('bio_profil').insert({
        'user_id'       : appUserId,
        'email'         : email,       // <-- tambah
        'university_id' : universityId,
      });
    } else {
      await SupabaseService.db
          .from('bio_profil')
          .update({'university_id': universityId})
          .eq('user_id', appUserId!);
    }

    debugPrint("SAVE UNIVERSITY SUCCESS => $universityId");
    return true;
  } catch (e) {
    debugPrint("SAVE UNIVERSITY ERROR => $e");
    return false;
  }
}

  // =========================================================
  // SAVE CV
  // =========================================================

  Future<bool> saveCvData() async {

    try {

      if (appUserId == null) return false;

      // tidak ada perubahan
      if (cvDocumentBytes == null) {

        debugPrint("CV NOT CHANGED");

        return true;
      }

      // TODO:
      // upload ke storage

      // contoh url hasil upload
      final uploadedUrl =
          currentCvUrl ?? '';

      await SupabaseService.db
          .from('mentor_cv')
          .upsert({

        'user_id' : appUserId,
        'cv_url'  : uploadedUrl,

      });

      currentCvUrl = uploadedUrl;

      return true;

    } catch (e) {

      debugPrint("SAVE CV ERROR => $e");

      return false;
    }
  }

  // =========================================================
  // PICK IMAGE
  // =========================================================

  Future<void> pickImage(ImageSource source) async {

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {

      profileImageBytes =
          await picked.readAsBytes();

      if (!kIsWeb) {

        profileImageFile =
            File(picked.path);
      }

      debugPrint("IMAGE PICKED");
    }
  }

  // =========================================================
  // PICK DOCUMENT
  // =========================================================

  Future<void> pickDocument() async {

    final result =
        await FilePicker.platform.pickFiles(

      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {

      cvFileName =
          result.files.single.name;

      cvDocumentBytes =
          result.files.single.bytes;

      if (!kIsWeb &&
          result.files.single.path != null) {

        cvDocumentFile =
            File(result.files.single.path!);
      }

      debugPrint("CV PICKED");
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  void dispose() {

    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();

    categoryController.dispose();
    universityController.dispose();
  }
}