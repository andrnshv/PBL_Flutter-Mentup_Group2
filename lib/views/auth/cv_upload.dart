import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class MentorCvUploadPage extends StatefulWidget {
  const MentorCvUploadPage({super.key});

  @override
  State<MentorCvUploadPage> createState() => _MentorCvUploadPageState();
}

class _MentorCvUploadPageState extends State<MentorCvUploadPage> {
  bool _isSubmitted = false;
  bool _isLoading   = false;
  String? _errorMessage;
  String? _selectedFileName;
  File?   _selectedFile;

  // Pilih file PDF dari device
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile     = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _errorMessage     = null;
      });
    }
  }

  Future<void> _uploadCV() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Pilih file PDF terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        setState(() => _errorMessage = 'Sesi tidak ditemukan, silakan login ulang.');
        return;
      }

      // 1. Upload PDF ke Supabase Storage bucket 'mentor-cv'
      final filePath = 'cv/${user.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await SupabaseService.storage
          .from('mentor-cv')
          .upload(filePath, _selectedFile!);

      // 2. Ambil public URL file yang diupload
      final cvUrl = SupabaseService.storage
          .from('mentor-cv')
          .getPublicUrl(filePath);

      // 3. Ambil data user dari tabel appuser
      final userData = await SupabaseService.db
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', user.id)
          .single();

      // 4. Insert ke tabel mentor_cv
      await SupabaseService.db.from('mentor_cv').insert({
        'user_id'     : user.id,
        'nama_lengkap': userData['nama_lengkap'],
        'email'       : userData['email'],
        'cv_url'      : cvUrl,
        'status'      : 'pending',
      });

      setState(() => _isSubmitted = true);

    } on StorageException catch (e) {
      setState(() => _errorMessage = 'Gagal upload file: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCDB4DB), Color(0xFFF5B3CE), Color(0xFFA7C7E7)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            if (!_isSubmitted) _buildBackButton(),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isSubmitted) ...[
                      const Text(
                        "Hello Mentor!",
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Submit your CV here before officially\nbecoming a mentor on our platform.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Kotak Upload
                      GestureDetector(
                        onTap: _isLoading ? null : _pickFile,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedFile != null
                                  ? Colors.green
                                  : const Color(0xFF333333),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFile != null
                                    ? Icons.check_circle_outline
                                    : Icons.cloud_upload_outlined,
                                size: 50,
                                color: _selectedFile != null
                                    ? Colors.green
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _selectedFile != null
                                    ? _selectedFileName!
                                    : "Drop or click here to upload your resume.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  color: _selectedFile != null
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "The format supported is PDF",
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Please wait, your account will be confirmed\nwithin 2x24 hours. Thank you for signing up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildUploadButton(),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
                    ] else ...[
                      const Icon(
                        Icons.access_time_filled,
                        color: Color(0xFFA7C7E7),
                        size: 90,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Please Wait...",
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Your CV has been successfully uploaded.\nOur admin is currently reviewing your profile.\nPlease check here periodically within the next 2x24 hours.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildBackToLoginButton(),
                      const SizedBox(height: 10),
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

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_outlined,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFFF5B3CE), Color(0xFFA7C7E7)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _uploadCV,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Sign Up",
                style: TextStyle(
                  fontFamily: 'Jost',
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFA7C7E7), width: 2),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          "Back to Login",
          style: TextStyle(
            fontFamily: 'Jost',
            color: Color(0xFFA7C7E7),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(fontFamily: 'Jost', fontSize: 16),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: const Text(
            "Log In",
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}