import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/client/edit_profile_controller.dart';
import '../../../models/client/edit_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController _controller = EditProfileController();

  final Color primary = const Color(0xFF6C63FF);

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();

  File? selectedImage;
  String? networkImage;

  bool isPhotoDeleted = false;
  bool isLoading = true;

  String? userEmail; // tetap dipakai untuk FK internal

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    debugPrint("=== LOAD PROFILE ===");

    final EditProfileModel? profile = await _controller.getProfile();

    if (profile != null) {
      nameController.text = profile.namaLengkap;
      addressController.text = profile.alamat;
      bioController.text = profile.bio;
      networkImage = profile.fotoUrl;
      userEmail = profile.email;

      debugPrint("PROFILE LOADED: ${profile.namaLengkap}");
    } else {
      debugPrint("FAILED LOAD PROFILE");
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
        isPhotoDeleted = false;
      });
    }
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
      networkImage = null;
      isPhotoDeleted = true;
    });
    Navigator.pop(context);
  }

  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove"),
              onTap: removeImage,
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    debugPrint("=== SAVE PROFILE ===");
    debugPrint("Name: ${nameController.text}");
    debugPrint("Address: ${addressController.text}");
    debugPrint("Bio: ${bioController.text}");

    String? imageUrl = networkImage;

    if (selectedImage != null) {
      imageUrl = await _controller.uploadImage(selectedImage!);
      debugPrint("IMAGE UPLOADED: $imageUrl");
    }

    final success = await _controller.updateProfile(
      namaLengkap: nameController.text,
      email: userEmail ?? '',
      alamat: addressController.text,
      bio: bioController.text,
      fotoUrl: isPhotoDeleted ? null : imageUrl,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: primary,
          content: const Text("Profile updated successfully"),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Edit Profile",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -60),
              child: Column(
                children: [
                  // PROFILE IMAGE
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (networkImage != null
                                  ? NetworkImage(networkImage!)
                                  : null) as ImageProvider?,
                          child: (selectedImage == null && networkImage == null)
                              ? Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                              ),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // FORM CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInput(
                            label: "Full Name",
                            controller: nameController,
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 15),

                          _buildInput(
                            label: "Alamat",
                            controller: addressController,
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 15),

                          _buildInput(
                            label: "About",
                            controller: bioController,
                            icon: Icons.info,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SAVE BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text("Save Changes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}