import 'package:flutter/material.dart';

import '../../controller/auth/register_controller.dart';
import '../../models/auth/register_model.dart';
import '../../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController _controller = RegisterController();

  String selectedRole = 'klien';

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  /// PASSWORD CRITERIA
  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;

  bool get _passwordValid =>
      _hasMinLength &&
      _hasUpperLower &&
      _hasNumber;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(
      _checkPasswordCriteria,
    );
  }

  void _checkPasswordCriteria() {
    final password = _passwordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;

      _hasUpperLower =
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'));

      _hasNumber =
          password.contains(RegExp(r'[0-9]'));
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

    /// VALIDATION
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {

      setState(() {
        _errorMessage = 'Semua field wajib diisi.';
      });

      return;
    }

    if (!_passwordValid) {

      setState(() {
        _errorMessage =
            'Password belum memenuhi kriteria.';
      });

      return;
    }

    if (_passwordController.text !=
        _confirmController.text) {

      setState(() {
        _errorMessage = 'Password tidak cocok.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    /// MODEL
    final model = RegisterModel(
      namaLengkap:
          _nameController.text.trim(),

      username:
          _usernameController.text.trim(),

      email:
          _emailController.text.trim(),

      password:
          _passwordController.text,

      role: selectedRole,
    );

    /// CONTROLLER
    final result =
        await _controller.register(model);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    /// SUCCESS
    if (result == null ||
        result == "EMAIL_ALREADY_REGISTERED") {

      _navigateAfterSuccess();

      return;
    }

    /// ERROR
    setState(() {
      _errorMessage = result;
    });
  }

  void _navigateAfterSuccess() {

    if (selectedRole == 'klien') {

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );

    } else {

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mentorCV,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight =
        MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,

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

        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Column(
            children: [

              const SizedBox(height: 60),

              _buildBackButton(),

              SizedBox(
                height: screenHeight * 0.05,
              ),

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
                    top: 30,
                    left: 30,
                    right: 30,
                    bottom: 40,
                  ),

                  child: Column(
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

                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// ERROR
                      if (_errorMessage != null)
                        _buildErrorBox(),

                      /// FULL NAME
                      _buildTextField(
                        "Full Name",
                        Icons.person_outline,
                        controller: _nameController,
                      ),

                      const SizedBox(height: 15),

                      /// USERNAME
                      _buildTextField(
                        "Username",
                        Icons.person_pin_outlined,
                        controller: _usernameController,
                      ),

                      const SizedBox(height: 15),

                      /// EMAIL
                      _buildTextField(
                        "Email Address",
                        Icons.email_outlined,
                        controller: _emailController,
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      _buildTextField(
                        "Password",
                        Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      /// PASSWORD CRITERIA
                      if (_passwordController
                          .text
                          .isNotEmpty) ...[

                        const SizedBox(height: 10),

                        _criteriaItem(
                          "At least 8 characters",
                          _hasMinLength,
                        ),

                        const SizedBox(height: 5),

                        _criteriaItem(
                          "Uppercase & Lowercase",
                          _hasUpperLower,
                        ),

                        const SizedBox(height: 5),

                        _criteriaItem(
                          "Include numbers",
                          _hasNumber,
                        ),
                      ],

                      const SizedBox(height: 15),

                      /// CONFIRM PASSWORD
                      _buildTextField(
                        "Confirm Password",
                        Icons.lock_reset_outlined,
                        controller: _confirmController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 25),

                      /// ROLE
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,

                        children: [

                          _buildRoleRadio(
                            "Klien",
                            "klien",
                          ),

                          _buildRoleRadio(
                            "Mentor",
                            "mentor",
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// BUTTON
                      _buildRegisterButton(),

                      const SizedBox(height: 15),

                      /// LOGIN LINK
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

  /// ================= ERROR =================
  Widget _buildErrorBox() {

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.red.shade50,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.red.shade200,
        ),
      ),

      child: Text(
        _errorMessage!,

        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 13,
        ),

        textAlign: TextAlign.center,
      ),
    );
  }

  /// ================= PASSWORD CRITERIA =================
  Widget _criteriaItem(
    String text,
    bool met,
  ) {

    return Row(
      children: [

        Icon(
          met
              ? Icons.check_circle
              : Icons.cancel,

          size: 16,

          color: met
              ? Colors.green
              : Colors.red.shade300,
        ),

        const SizedBox(width: 8),

        Text(
          text,

          style: TextStyle(
            fontSize: 12,

            color: met
                ? Colors.green
                : Colors.red.shade300,
          ),
        ),
      ],
    );
  }

  /// ================= ROLE RADIO =================
  Widget _buildRoleRadio(
    String label,
    String value,
  ) {

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = value;
        });
      },

      child: Row(
        children: [

          Radio<String>(
            value: value,
            groupValue: selectedRole,

            activeColor: Colors.blue,

            onChanged: (v) {
              setState(() {
                selectedRole = v!;
              });
            },
          ),

          Text(
            label,

            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= BACK BUTTON =================
  Widget _buildBackButton() {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Align(
        alignment: Alignment.centerLeft,

        child: CircleAvatar(
          backgroundColor: Colors.white24,

          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),

            onPressed: () {

              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.welcome,
                (_) => false,
              );
            },
          ),
        ),
      ),
    );
  }

  /// ================= TEXT FIELD =================
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

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide: const BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
    );
  }

  /// ================= REGISTER BUTTON =================
  Widget _buildRegisterButton() {

    return Container(
      width: double.infinity,
      height: 55,

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),

        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8B5C5),
            Color(0xFFB5D8F7),
          ],
        ),
      ),

      child: ElevatedButton(
        onPressed:
            _isLoading ? null : _register,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,

                child:
                    CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )

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

  /// ================= LOGIN LINK =================
  Widget _buildLoginLink() {

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        const Text(
          "Already have an account? ",
        ),

        GestureDetector(
          onTap: () {

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          },

          child: const Text(
            "Log In",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}