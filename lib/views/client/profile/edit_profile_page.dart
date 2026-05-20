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

  final Color primaryPurple = const Color(0xFFB58AE3);
  final Color primaryBlue = const Color(0xFF8FA8F8);

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();

  File? selectedImage;
  String? networkImage;

  bool isPhotoDeleted = false;
  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final EditProfileModel? profile = await _controller.getProfile();

    if (profile != null) {
      nameController.text = profile.namaLengkap;
      addressController.text = profile.alamat;
      bioController.text = profile.bio;
      networkImage = profile.fotoUrl;
      userEmail = profile.email;
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

    String? imageUrl = networkImage;

    if (selectedImage != null) {
      imageUrl = await _controller.uploadImage(selectedImage!);
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
        const SnackBar(content: Text("Profile updated")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFCEA7E8),
                        Color(0xFF94A9F4),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),

                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          const Expanded(
                            child: Center(
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                  ),
                ),

                // ================= PROFILE IMAGE =================
                Positioned(
                  bottom: -55,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade200,

                            backgroundImage: selectedImage != null
                                ? FileImage(selectedImage!)
                                : (networkImage != null &&
                                        networkImage!.isNotEmpty)
                                    ? NetworkImage(networkImage!)
                                        as ImageProvider
                                    : null,

                            child: (selectedImage == null &&
                                    (networkImage == null ||
                                        networkImage!.isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 45,
                                    color: Colors.grey,
                                  )
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
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryPurple,
                                    primaryBlue,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 75),

            // ================= CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TITLE =====
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.person,
                            color: primaryPurple,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              "Update your account details",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ===== FULL NAME =====
                    const Text(
                      "Full Name",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildInput(
                      controller: nameController,
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    // ===== ADDRESS =====
                    const Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildInput(
                      controller: addressController,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 18),

                    // ===== ABOUT =====
                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildInput(
                      controller: bioController,
                      icon: Icons.info_outline,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 25),

                    // ===== BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saveProfile,

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                        ),

                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryPurple,
                                primaryBlue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: const Center(
                            child: Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: primaryPurple,
          size: 20,
        ),

        filled: true,
        fillColor: const Color(0xFFF5F5F7),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryPurple,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}