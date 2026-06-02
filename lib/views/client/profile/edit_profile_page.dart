import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../../controller/client/edit_profile_controller.dart';
import '../../../models/client/edit_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController _controller = EditProfileController();

  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color primaryBlue = const Color(0xFF6D92CB);
  final Color bgGray = const Color(0xFFF8F9FB);
  final Color textDark = const Color(0xFF2D3436);

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController bioController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    addressController = TextEditingController();
    bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final EditProfileModel? profile = await _controller.getProfile();

    if (profile != null && mounted) {
      nameController.text = profile.namaLengkap;
      addressController.text = profile.alamat;
      bioController.text = profile.bio;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      CherryToast.error(
        title: const Text("Validation Error"),
        description: const Text("Name cannot be empty!"),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl = _controller.currentFotoUrl;

    // Upload foto jika ada yang dipilih
    if (_controller.selectedImageFile != null) {
      photoUrl = await _controller.uploadImage(_controller.selectedImageFile!);
    }

    final success = await _controller.updateProfile(
      namaLengkap: nameController.text,
      email: _controller.currentEmail ?? '',
      alamat: addressController.text,
      bio: bioController.text,
      fotoUrl: photoUrl,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      CherryToast.success(
        title: const Text("Success"),
        description: const Text("Profile updated successfully!"),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
      Navigator.pop(context);
    } else {
      CherryToast.error(
        title: const Text("Failed"),
        description: const Text("Failed to update profile"),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgGray,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── HEADER & FOTO PROFIL ───
            Stack(
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFCDB4DB),
                        primaryPurple,
                        primaryBlue,
                        const Color(0xFFCDB4DB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 175),
                  alignment: Alignment.topCenter,
                  child: _buildProfileImage(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── KONTEN FORM ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════ FORM SECTION: PERSONAL INFORMATION ═══════
                  _buildFormSection(
                    title: "Personal Information",
                    icon: Icons.badge_outlined,
                    children: [
                      _buildCustomField(
                        "Full Name",
                        nameController,
                        Icons.person_outline,
                      ),
                      _buildCustomField(
                        "Location / Address",
                        addressController,
                        Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      _buildCustomField(
                        "Bio",
                        bioController,
                        Icons.edit_note_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      // TOMBOL SAVE
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B62CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Profile",
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final bool hasLocalImage = _controller.selectedImageFile != null;
    final bool hasNetworkImage =
        _controller.currentFotoUrl != null &&
        _controller.currentFotoUrl!.isNotEmpty;

    ImageProvider? imageProvider;

    if (hasLocalImage) {
      imageProvider = FileImage(_controller.selectedImageFile!);
    } else if (hasNetworkImage) {
      imageProvider = NetworkImage(_controller.currentFotoUrl!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: bgGray,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Icons.person, size: 48, color: Colors.grey.shade400)
                : null,
          ),
        ),
        GestureDetector(
          onTap: _showImagePickerBottomSheet,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt_rounded,
              color: primaryPurple,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: textDark,
                ),
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(
            icon,
            color: primaryPurple.withOpacity(0.5),
            size: 20,
          ),
          filled: true,
          fillColor: bgGray,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primaryPurple.withOpacity(0.5),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Select photo source",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.blue[700],
                  ),
                ),
                title: const Text(
                  "Take a picture",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _controller.pickImage(ImageSource.camera);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Colors.purple[700],
                  ),
                ),
                title: const Text(
                  "Choose from gallery",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _controller.pickImage(ImageSource.gallery);
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}