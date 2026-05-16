import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../../controller/mentor/edit_profile_controller.dart';

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

  bool _isLoading = true;
  bool _isSavingBio = false;
  bool _isSavingCategory = false;
  bool _isSavingUniv = false;
  bool _isSavingCV = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadProfile();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            // --- HEADER & FOTO PROFIL ---
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

            // --- KONTEN FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= CARD 1: PERSONAL INFORMATION =================
                  _buildFormSection(
                    title: "Personal Information",
                    icon: Icons.badge_outlined,
                    children: [
                      _buildCustomField(
                        "Full Name",
                        _controller.nameController,
                        Icons.person_outline,
                      ),
                      _buildCustomField(
                        "Username",
                        _controller.usernameController,
                        Icons.alternate_email,
                      ),
                      _buildCustomField(
                        "WhatsApp Number",
                        _controller.phoneController,
                        Icons.phone_android_outlined,
                        isNumber: true,
                      ),
                      _buildCustomField(
                        "Keahlian",
                        _controller.keahlianController,
                        Icons.work_outline,
                      ),
                      _buildCustomField(
                        "Bimble Location",
                        _controller.addressController,
                        Icons.location_on_outlined,
                      ),
                      _buildCustomField(
                        "Bio",
                        _controller.bioController,
                        Icons.edit_note_rounded,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 20),
                      // TOMBOL SUBMIT BIO (CARD 1)
                      SizedBox(
                        width: double
                            .infinity, // Bikin tombol menuhin space kiri ke kanan
                        height: 50, // Tinggi konsisten
                        child: ElevatedButton(
                          onPressed: _isSavingBio ? null : _saveBioData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B62CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0, // Dibuat flat biar lebih modern
                          ),
                          child: _isSavingBio
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Info",
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

                  const SizedBox(height: 30),

                  // ================= JUDUL YOUR PROFILE =================
                  // ================= CARD 2: CATEGORY =================
                  _buildFormSection(
                    title: "Your Profile", // <-- JUDUL DAN ICON ASLI KEMBALI
                    icon: Icons.auto_awesome_outlined,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _controller.selectedCategory,
                        items: _controller.categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _controller.selectedCategory = val;
                          });
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(
                          labelText: "Teaching Category",
                          labelStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7E7BB9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: Color(0xFF7E7BB9),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (_controller.selectedCategory == "Lainnya") ...[
                        const SizedBox(height: 20),
                        _buildCustomField(
                          "Enter specific category",
                          _controller.categoryController,
                          Icons.edit,
                        ),
                      ],

                      const SizedBox(height: 20),
                      // TOMBOL SUBMIT CATEGORY (CARD 2)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSavingCategory
                              ? null
                              : _saveCategoryData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E7BB9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSavingCategory
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Category",
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

                  const SizedBox(height: 20),

                  // ================= CARD 3: UNIVERSITY =================
                  _buildFormSection(
                    title: "University / Institution",
                    icon: Icons.school_outlined,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _controller.selectedUniversity,
                        items: _controller.universities
                            .map(
                              (uni) => DropdownMenuItem(
                                value: uni,
                                child: Text(
                                  uni,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _controller.selectedUniversity = val;
                          });
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(
                          labelText: "University / Campus",
                          labelStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7E7BB9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF7E7BB9),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (_controller.selectedUniversity == "Lainnya") ...[
                        const SizedBox(height: 20),
                        _buildCustomField(
                          "Enter university name",
                          _controller.universityController,
                          Icons.edit,
                        ),
                      ],

                      const SizedBox(height: 20),
                      // TOMBOL SUBMIT UNIV (CARD 3)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSavingUniv ? null : _saveUniversityData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D92CB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSavingUniv
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Education",
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

                  const SizedBox(height: 20),

                  // ================= CARD 4: CURRICULUM VITAE =================
                  _buildFormSection(
                    title: "Curriculum Vitae (CV)",
                    icon: Icons.folder_open_rounded,
                    children: [
                      _buildCVTile(),

                      const SizedBox(height: 20),
                      // TOMBOL SUBMIT CV (CARD 4)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSavingCV ? null : _saveCvData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCDB4DB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isSavingCV
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Document",
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

                  // Hilangkan _buildSaveButton() milikmu yang lama, berikan jarak bawah
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
    final bool hasLocalImage = _controller.profileImageBytes != null;
    final bool hasNetworkImage =
        _controller.currentFotoUrl != null &&
        _controller.currentFotoUrl!.isNotEmpty;

    ImageProvider? imageProvider;

    if (hasLocalImage) {
      imageProvider = MemoryImage(_controller.profileImageBytes!);
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
          onTap: () => _showImagePickerBottomSheet(context),
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
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
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

  Widget _buildCVTile() {
    final String displayText =
        _controller.cvFileName ??
        (_controller.currentCvUrl != null &&
                _controller.currentCvUrl!.isNotEmpty
            ? _controller.currentCvUrl!.split('/').last
            : "Belum ada CV");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.pickDocument();
              if (mounted) setState(() {});
            },
            child: Text("Change", style: TextStyle(color: primaryBlue)),
          ),
        ],
      ),
    );
  }

  // 1. Fungsi Simpan Bio (Akan memanggil API update bio)
  Future<void> _saveBioData() async {
    // Validasi khusus Bio
    if (_controller.nameController.text.trim().isEmpty) {
      CherryToast.error(
        title: const Text(
          "Save Failed",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "Name cannot be empty!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    setState(() => _isSavingBio = true);

    // TODO: Minta temanmu buat fungsi khusus di controller, misal: _controller.updateBio()
    // bool success = await _controller.updateBio();
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Hapus ini jika API sudah siap
    bool success = true; // Simulasi sukses

    if (!mounted) return;
    setState(() => _isSavingBio = false);

    if (success) {
      CherryToast.success(
        title: const Text(
          "Profile Updated",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "Your personal info has been saved!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  // 2. Fungsi Simpan Kategori
  Future<void> _saveCategoryData() async {
    setState(() => _isSavingCategory = true);

    // TODO: Panggil API khusus Kategori dari controller
    // bool success = await _controller.updateCategory();
    await Future.delayed(const Duration(seconds: 1));
    bool success = true;

    if (!mounted) return;
    setState(() => _isSavingCategory = false);

    if (success) {
      CherryToast.success(
        title: const Text(
          "Category Updated",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "Teaching category successfully saved!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  // 3. Fungsi Simpan Universitas
  Future<void> _saveUniversityData() async {
    setState(() => _isSavingUniv = true);

    // TODO: Panggil API khusus Universitas dari controller
    // bool success = await _controller.updateUniversity();
    await Future.delayed(const Duration(seconds: 1));
    bool success = true;

    if (!mounted) return;
    setState(() => _isSavingUniv = false);

    if (success) {
      CherryToast.success(
        title: const Text(
          "University Updated",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "Your education info has been saved!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  // 4. Fungsi Simpan CV
  Future<void> _saveCvData() async {
    setState(() => _isSavingCV = true);

    // TODO: Panggil API khusus Dokumen CV dari controller
    // bool success = await _controller.updateCV();
    await Future.delayed(const Duration(seconds: 1));
    bool success = true;

    if (!mounted) return;
    setState(() => _isSavingCV = false);

    if (success) {
      CherryToast.success(
        title: const Text(
          "Document Updated",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "Your CV has been successfully uploaded!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  void _showImagePickerBottomSheet(BuildContext context) {
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_open_rounded,
                    color: Colors.orange[700],
                  ),
                ),
                title: const Text(
                  "Choose from File or Drive",
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
