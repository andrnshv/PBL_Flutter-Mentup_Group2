import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool    _rememberMe   = false;
  bool    _isLoading    = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email dan password wajib diisi.');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user == null) {
        setState(() => _errorMessage = 'Login gagal. Coba lagi.');
        return;
      }

      // Ambil role dari tabel appuser
      final userData = await SupabaseService.db
          .from('appuser')
          .select('role')
          .eq('id', response.user!.id)
          .single();

      if (!mounted) return;

      final role = userData['role'] as String;

      if (role == 'mentor') {
        // Cek apakah CV sudah diupload & statusnya
        final cvData = await SupabaseService.db
            .from('mentor_cv')
            .select('status')
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (!mounted) return;

        if (cvData == null) {
          // Belum upload CV
          Navigator.pushNamedAndRemoveUntil(
              context, '/mentor_cv', (_) => false);
        } else if (cvData['status'] == 'approved') {
          Navigator.pushNamedAndRemoveUntil(
              context, '/mentor_landing', (_) => false);
        } else {
          // Status pending atau rejected
          Navigator.pushNamedAndRemoveUntil(
              context, '/mentor_cv', (_) => false);
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/landing', (_) => false);
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
      body: Container(
        width: double.infinity,
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
            _buildBackButton(),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Log in to your registered account.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
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

                      _buildTextField(
                        "Email",
                        Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Password",
                        Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      _buildForgotSection(),
                      const SizedBox(height: 30),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildSignUpLink(),
                    ],
                  ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _buildForgotSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              shape: const CircleBorder(),
              onChanged: (val) => setState(() => _rememberMe = val!),
            ),
            const Text("Remember me", style: TextStyle(color: Colors.blue)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Forgot password?",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
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
        onPressed: _isLoading ? null : _login,
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
                "Log In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            "Sign Up",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}