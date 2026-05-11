import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String selectedRole = 'klien';

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Kriteria password
  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;

  bool get _passwordValid => _hasMinLength && _hasUpperLower && _hasNumber;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordCriteria);
  }

  void _checkPasswordCriteria() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperLower = password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

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
    // 1. Validasi Sederhana
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Semua field wajib diisi.');
      return;
    }

    if (!_passwordValid) {
      setState(() => _errorMessage = 'Password belum memenuhi kriteria.');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 2. Auth SignUp
      final response = await SupabaseService.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'nama_lengkap': _nameController.text.trim(),
          'role': selectedRole,
        },
      );

      final user = response.user;
      if (user == null) throw Exception("Gagal mendapatkan data user.");

      // 3. Database Upsert (Gunakan upsert agar jika record ada, dia hanya update)
      // Ini menangani kasus jika user sudah register auth tapi proses tabel terhenti
      await SupabaseService.db.from('appuser').upsert({
        'id': user.id,
        'nama_lengkap': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': selectedRole,
      }, onConflict: 'id');

      await SupabaseService.db.from('bio_profil').upsert({
        'email': _emailController.text.trim(),
        'nama_lengkap': _nameController.text.trim(),
      }, onConflict: 'email');

      if (!mounted) return;
      _navigateAfterSuccess();

    } on AuthException catch (e) {
      // Jika error karena email sudah terdaftar, langsung arahkan ke login/tujuan
      if (e.message.toLowerCase().contains("already registered")) {
        _navigateAfterSuccess();
      } else {
        setState(() => _errorMessage = "Akun: ${e.message}");
      }
    } on PostgrestException catch (e) {
      // Error Database/RLS
      setState(() => _errorMessage = "Database: ${e.message}");
      print("DB Error Code: ${e.code}");
    } catch (e) {
      // Error Umum (Internet/Lainnya)
      setState(() => _errorMessage = "Terjadi kesalahan: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateAfterSuccess() {
    if (selectedRole == 'klien') {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mentorCV, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCDB4DB), Color(0xFFF5B3CE), Color(0xFFA7C7E7)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildBackButton(),
              SizedBox(height: screenHeight * 0.05),
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
                    top: 30, left: 30, right: 30, bottom: 40,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Fill the form and select your role",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 25),

                      if (_errorMessage != null) _buildErrorBox(),

                      _buildTextField("Full Name", Icons.person_outline, controller: _nameController),
                      const SizedBox(height: 15),
                      _buildTextField("Username", Icons.person_pin_outlined, controller: _usernameController),
                      const SizedBox(height: 15),
                      _buildTextField("Email Address", Icons.email_outlined, controller: _emailController),
                      const SizedBox(height: 15),
                      _buildTextField("Password", Icons.lock_outline, controller: _passwordController, isPassword: true),

                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _criteriaItem("At least 8 characters", _hasMinLength),
                        const SizedBox(height: 5),
                        _criteriaItem("Uppercase & Lowercase", _hasUpperLower),
                        const SizedBox(height: 5),
                        _criteriaItem("Include numbers", _hasNumber),
                      ],

                      const SizedBox(height: 15),
                      _buildTextField("Confirm Password", Icons.lock_reset_outlined, controller: _confirmController, isPassword: true),
                      
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRoleRadio("Klien", "klien"),
                          _buildRoleRadio("Mentor", "mentor"),
                        ],
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
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildErrorBox() {
    return Container(
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
        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _criteriaItem(String text, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle : Icons.cancel, size: 16, color: met ? Colors.green : Colors.red.shade300),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: met ? Colors.green : Colors.red.shade300)),
      ],
    );
  }

  Widget _buildRoleRadio(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => selectedRole = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedRole,
            activeColor: Colors.blue,
            onChanged: (v) => setState(() => selectedRole = v!),
          ),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {required TextEditingController controller, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.black12)),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFFF8B5C5), Color(0xFFB5D8F7)]),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false),
          child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
      ],
    );
  }
}