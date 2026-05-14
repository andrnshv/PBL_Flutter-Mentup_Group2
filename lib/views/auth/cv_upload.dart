import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../controller/auth/cv_upload_controller.dart';
import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

class MentorCvUploadPage extends StatefulWidget {
  const MentorCvUploadPage({super.key});

  @override
  State<MentorCvUploadPage> createState() => _MentorCvUploadPageState();
}

class _MentorCvUploadPageState extends State<MentorCvUploadPage> {
  final CvUploadController _controller = CvUploadController();

  bool _isSubmitted = false;
  bool _isLoading = false;
  bool _isCheckingStatus = true;

  String? _errorMessage;
  String? _selectedFileName;

  File? _selectedFile;
  Uint8List? _selectedFileBytes;

  bool get _fileReady =>
      kIsWeb ? _selectedFileBytes != null : _selectedFile != null;

  @override
  void initState() {
    super.initState();
    _checkCvStatus();
  }

  /// =========================
  /// CHECK STATUS CV
  /// =========================
  Future<void> _checkCvStatus() async {
    final user = SupabaseService.currentUser;

    if (user == null) {
      setState(() => _isCheckingStatus = false);
      return;
    }

    final result = await _controller.checkCvStatus(user.id);

    setState(() {
      _isSubmitted = result;
      _isCheckingStatus = false;
    });

    debugPrint("CV STATUS: $_isSubmitted");
  }

  /// =========================
  /// PICK FILE PDF
  /// =========================
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );

      if (result == null) return;

      final file = result.files.single;

      setState(() {
        _selectedFileName = file.name;
        _errorMessage = null;

        if (kIsWeb) {
          _selectedFileBytes = file.bytes;
          _selectedFile = null;
        } else {
          if (file.path != null) {
            _selectedFile = File(file.path!);
            _selectedFileBytes = null;
          }
        }
      });

      debugPrint("FILE SELECTED: ${file.name}");
    } catch (e) {
      setState(() => _errorMessage = "File picker error: $e");
    }
  }

  /// =========================
  /// UPLOAD CV FLOW
  /// =========================
  Future<void> _uploadCV() async {
    final user = SupabaseService.currentUser;

    if (user == null) {
      setState(() => _errorMessage = "User tidak ditemukan");
      return;
    }

    if (!_fileReady) {
      setState(() => _errorMessage = "Pilih file PDF terlebih dahulu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint("=== UPLOAD START ===");

      /// 1. GET USER DATA
      final userData = await _controller.getUserData(user.id);

      if (userData == null) {
        setState(() => _errorMessage = "Gagal ambil data user");
        return;
      }

      debugPrint("USER DATA OK: $userData");

      /// 2. UPLOAD FILE TO STORAGE
      final cvUrl = await _controller.uploadCvFile(
        userId: user.id,
        file: _selectedFile,
        bytes: _selectedFileBytes,
      );

      if (cvUrl == null) {
        setState(() => _errorMessage = "Upload file gagal");
        return;
      }

      debugPrint("UPLOAD SUCCESS URL: $cvUrl");

      /// 3. SAVE TO DATABASE
      final success = await _controller.submitCv(
        userId: user.id,
        cvUrl: cvUrl,
        userData: userData,
      );

      debugPrint("DB SAVE RESULT: $success");

      if (success) {
        setState(() => _isSubmitted = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("CV berhasil diupload"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorMessage = "Gagal simpan ke database");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
      debugPrint("UPLOAD ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    if (_isCheckingStatus) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCDB4DB),
              Color(0xFFF5B3CE),
              Color(0xFFA7C7E7),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),

            if (!_isSubmitted)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (_) => false,
                ),
              ),

            const Spacer(),

            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(80),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isSubmitted) ...[
                      const Text(
                        "Hello Mentor!",
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Submit your CV here before officially\nbecoming a mentor.",
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),

                      const SizedBox(height: 10),

                      /// FILE UPLOAD BOX
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _fileReady
                                  ? Colors.green
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _fileReady
                                    ? Icons.check_circle
                                    : Icons.cloud_upload,
                                size: 50,
                                color: _fileReady
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selectedFileName ??
                                    "Tap to upload PDF CV",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : _uploadCV,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Submit CV"),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        size: 90,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 10),
                      const Text("CV Successfully Uploaded"),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}