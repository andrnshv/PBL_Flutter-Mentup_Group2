import 'package:flutter/material.dart';
import 'package:flutter_mentup/controller/mentor/edit_profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // Wajib ditambahin buat format input

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final EditProfileController _controller = EditProfileController();

  // Muted Tech Color Palette
  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color primaryBlue = const Color(0xFF6D92CB);
  final Color bgGray = const Color(0xFFF8F9FB);
  final Color textDark = const Color(0xFF2D3436);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _controller.loadData(args);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      // Supaya gradasi header bisa mulus sampai ke ujung atas layar (status bar)
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
                // 1. Background Gradasi
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFCDB4DB),
                        primaryPurple,
                        primaryBlue,
                        Color(0xFFCDB4DB),
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
                // 2. Foto Profil & Kamera
                // Menggunakan margin agar posisinya turun, tapi tetap "diakui" ada di dalam layar
                Container(
                  margin: const EdgeInsets.only(
                    top: 175,
                  ), // 230 (tinggi gradasi) - 55 (setengah ukuran foto)
                  alignment: Alignment.topCenter,
                  child: _buildProfileImage(),
                ),
              ],
            ),

            // Jarak tambahan sedikit saja karena fotonya sekarang sudah memakan ruang
            const SizedBox(height: 20),

            // --- BAGIAN FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Section: Informasi Dasar
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Section: Identitas Mentor
                  _buildFormSection(
                    title: "Your Profile",
                    icon: Icons.auto_awesome_outlined,
                    children: [
                      _buildCustomField(
                        "Headline",
                        _controller.headlineController,
                        Icons.work_outline,
                      ),
                      _buildCustomField(
                        "Teaching Experience (Years)",
                        _controller.experienceController,
                        Icons.history_edu_rounded,
                        isNumber: true,
                        // Jika kamu ingin keyboardnya hanya angka, tambahkan parameter TextInputType di _buildCustomField asli kamu
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Section: Dokumen (CV)
                  _buildFormSection(
                    title: "Curriculum Vitae (CV)",
                    icon: Icons.folder_open_rounded,
                    children: [_buildCVTile()],
                  ),

                  const SizedBox(height: 40),

                  // Tombol Simpan
                  _buildSaveButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desain Foto Profil
  Widget _buildProfileImage() {
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
            backgroundImage: _controller.profileImageBytes != null
                ? MemoryImage(_controller.profileImageBytes!)
                      as ImageProvider // Jika ada foto (Support Web & Mobile)
                : const AssetImage(
                    'assets/mentor.png',
                  ), // Jika belum, pakai avatar bawaan
            // Path asli kamu
          ),
        ),
        // Tombol Kamera Mini
        GestureDetector(
          onTap: () {
            _showImagePickerBottomSheet(context);
          },
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

  // Wrapper untuk setiap card form
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

  // Desain Input Field yang elegan dan tulisan jelas
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

  // Desain bagian CV
  Widget _buildCVTile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _controller.cvFileName ??
                  "cv_lovie_terbaru.pdf", // Tampilkan nama file baru jika ada
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              overflow: TextOverflow
                  .ellipsis, // Biar kalau namanya kepanjangan jadi titik-titik
            ),
          ),
          TextButton(
            onPressed: () async {
              await _controller.pickDocument(); // Buka file explorer
              setState(() {}); // Refresh layar agar nama PDF-nya berubah
            },
            child: Text(
              "Change",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // Desain Tombol Simpan
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: () {
          _controller.saveProfile();
          Navigator.pop(context, {
            'name': _controller.nameController.text,
            'username': _controller.usernameController.text,
            'headline': _controller.headlineController.text,
            'bio': _controller.bioController.text,
            'phone': _controller.phoneController.text,
            'address': _controller.addressController.text,
            'imageBytes': _controller.profileImageBytes,
            'cvFileName': _controller.cvFileName, // Bawa pulang nama file
            'cvDocumentBytes': _controller.cvDocumentBytes,
            'experience': _controller.experienceController.text,
          });
        },
        child: const Text(
          "Save Changes",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // FUNGSI BOTTOM SHEET YANG SUDAH DILENGKAPI 3 OPSI
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
              // Garis kecil di atas bottom sheet (biar estetik)
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

              // Opsi 1: Kamera
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
                  await _controller.pickImage(
                    ImageSource.camera,
                  ); // BUKA KAMERA
                  setState(() {}); // Refresh layar
                },
              ),

              // Opsi 2: Galeri
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
                  "Choose from galery",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _controller.pickImage(
                    ImageSource.gallery,
                  ); // BUKA GALERI
                  setState(() {}); // Refresh layar
                },
              ),

              // Opsi 3: File Explorer / Google Drive
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
                onTap: () {
                  Navigator.pop(context);
                  // Nanti diisi logika package file_picker
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
