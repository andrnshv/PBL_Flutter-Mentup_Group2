import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Package Kamera/Galeri
import 'package:file_picker/file_picker.dart';

class EditProfileController {
  // Deklarasi semua controller
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController headlineController;
  late TextEditingController addressController;
  late TextEditingController bioController;
  late TextEditingController experienceController;

  // Variabel penampung File (Foto & CV)
  File? profileImage;
  Uint8List? profileImageBytes;
  File? cvDocument;
  Uint8List? cvDocumentBytes;
  String? cvFileName;

  bool _isDataLoaded = false;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk menerima data dari halaman sebelumnya
  void loadData(Map<String, dynamic>? args) {
    if (_isDataLoaded) return; // Mencegah load ulang saat hot reload

    if (args != null) {
      nameController = TextEditingController(text: args['name']);
      usernameController = TextEditingController(text: args['username']);
      phoneController = TextEditingController(text: args['phone']);
      headlineController = TextEditingController(text: args['headline']);
      addressController = TextEditingController(text: args['address']);
      bioController = TextEditingController(text: args['bio']);
      profileImageBytes = args['imageBytes'];
      cvFileName = args['cvFileName']; // Tangkap nama file CV
      cvDocumentBytes = args['cvDocumentBytes'];
      experienceController = TextEditingController(
        text: args['experience']?.toString(),
      );
    } else {
      // Jika kosong, inisiasi controller kosong
      nameController = TextEditingController();
      usernameController = TextEditingController();
      phoneController = TextEditingController();
      headlineController = TextEditingController();
      addressController = TextEditingController();
      bioController = TextEditingController();
    }

    _isDataLoaded = true;
  }

  // --- FUNGSI AMBIL FOTO (KAMERA / GALERI) ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // Membaca foto sebagai Bytes (Cara paling aman untuk Web dan Mobile)
        profileImageBytes = await pickedFile.readAsBytes();

        // Tetap simpan File-nya (opsional, berguna nanti saat di-run di Mobile)
        profileImage = File(pickedFile.path);

        print("Foto sukses dipilih! Path/Blob: ${pickedFile.path}");
      }
    } catch (e) {
      print("Gagal mengambil foto: $e");
    }
  }

  // --- FUNGSI AMBIL FILE PDF (FILE EXPLORER / DRIVE) ---
  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Hanya izinkan PDF
        withData: true, // <--- KUNCI PENTING UNTUK FLUTTER WEB
      );

      if (result != null) {
        // Ambil nama file-nya untuk ditampilkan di UI
        cvFileName = result.files.single.name;

        // Simpan datanya sebagai Bytes (Aman untuk Web & Mobile)
        cvDocumentBytes = result.files.single.bytes;

        // Kalau jalan di Mobile, kita tetap bisa simpan format File-nya
        if (result.files.single.path != null) {
          cvDocument = File(result.files.single.path!);
        }

        print("CV berhasil dipilih: $cvFileName");
      }
    } catch (e) {
      print("Gagal mengambil dokumen: $e");
    }
  }

  // Fungsi untuk menyimpan data (Nantinya untuk dikirim ke Database)
  void saveProfile() {
    print("Menyimpan data...");
    print("Nama: ${nameController.text}");
    print("Bio: ${bioController.text}");
    // Nanti logika API / Database ditaruh di sini
  }

  // Jangan lupa buang sampah memori
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    headlineController.dispose();
    addressController.dispose();
    bioController.dispose();
    experienceController.dispose();
  }
}
