import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String selectedRole = 'klien';

  final _nameController     = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Semua field wajib diisi.');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Password tidak cocok.');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    try {
      // 1. Daftar ke Supabase Auth
      final response = await SupabaseService.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'nama_lengkap': _nameController.text.trim(),
          'role'        : selectedRole,
        },
      );

      if (response.user == null) {
        setState(() => _errorMessage = 'Gagal mendaftar. Coba lagi.');
        return;
      }

      // 2. Insert ke tabel appuser
      await SupabaseService.db.from('appuser').insert({
        'id'          : response.user!.id,
        'nama_lengkap': _nameController.text.trim(),
        'username'    : _usernameController.text.trim(),
        'email'       : _emailController.text.trim(),
        'role'        : selectedRole,
      });

      // 3. Insert ke tabel bio_profil
      await SupabaseService.db.from('bio_profil').insert({
        'email'       : _emailController.text.trim(),
        'nama_lengkap': _nameController.text.trim(),
      });

      if (!mounted) return;

      // 4. Navigasi — semua ke login dulu
      if (selectedRole == 'klien') {
        // Klien → login dulu baru ke beranda
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (_) => false);
      } else {
        // Mentor → upload CV dulu, nanti login setelah approved
        Navigator.pushNamedAndRemoveUntil(
            context, '/mentor_cv', (_) => false);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            _buildBackButton(),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30, left: 30, right: 30, bottom: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Fill the form and select your role",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 25),

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

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTextField(
                              "Full Name",
                              Icons.person_outline,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Username",
                              Icons.person_pin_outlined,
                              controller: _usernameController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Email Address",
                              Icons.email_outlined,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Password",
                              Icons.lock_outline,
                              controller: _passwordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Confirm Password",
                              Icons.lock_reset_outlined,
                              controller: _confirmController,
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pilihan Role
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRoleRadio("Klien",  "klien"),
                          _buildRoleRadio("Mentor", "mentor"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                    const SizedBox(height: 15),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRadio(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => selectedRole = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedRole,
            activeColor: Colors.blue,
            onChanged: (v) => setState(() => selectedRole = v!),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          backgroundColor: Colors.white24,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon, {
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8B5C5), Color(0xFFB5D8F7)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: const Text(
            "Log In",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}