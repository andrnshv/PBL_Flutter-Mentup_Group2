import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EditProfileController {
  /// ================= CONTROLLERS =================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController headlineController = TextEditingController();

  /// ================= IMAGE =================
  Uint8List? profileImageBytes;

  /// ================= LOAD DATA =================
  void loadData(Map<String, dynamic>? data) {
    if (data == null) return;

    nameController.text = data['name'] ?? '';
    usernameController.text = data['username'] ?? '';
    phoneController.text = data['phone'] ?? '';
    addressController.text = data['address'] ?? '';
    bioController.text = data['bio'] ?? '';
    headlineController.text = data['headline'] ?? data['category'] ?? '';

    // kalau kamu kirim imageBytes dari halaman sebelumnya
    if (data['imageBytes'] != null) {
      profileImageBytes = data['imageBytes'];
    }
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        profileImageBytes = await pickedFile.readAsBytes();
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  /// ================= SAVE =================
  void saveProfile() {
    // nanti bisa kamu sambungkan ke API / Firebase
    debugPrint("Profile saved");
  }

  /// ================= GET DATA =================
  Map<String, dynamic> getData() {
    return {
      'name': nameController.text,
      'username': usernameController.text,
      'headline': headlineController.text,
      'bio': bioController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'imageBytes': profileImageBytes,
    };
  }

  /// ================= DISPOSE =================
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    headlineController.dispose();
  }
}
