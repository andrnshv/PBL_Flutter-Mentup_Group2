import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controller/auth/login_controller.dart';
import '../../models/auth/login_model.dart';
import '../../services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final LoginController _controller =
      LoginController();

  final _identifierController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _rememberMe = false;

  bool _isLoading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser()
  async {

    final savedIdentifier =
        await _controller
            .getSavedIdentifier();

    if (savedIdentifier != null) {

      setState(() {
        _rememberMe = true;

        _identifierController.text =
            savedIdentifier;
      });
    }
  }

  @override
  void dispose() {

    _identifierController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {

    if (_identifierController.text
            .trim()
            .isEmpty ||
        _passwordController
            .text
            .isEmpty) {

      setState(() {
        _errorMessage =
            'Email/username dan password wajib diisi.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    /// MODEL
    final model = LoginModel(
      identifier:
          _identifierController.text.trim(),

      password:
          _passwordController.text,

      rememberMe: _rememberMe,
    );

    /// LOGIN
    final result =
        await _controller.login(model);

    if (!mounted) return;

    if (result != null) {

      setState(() {
        _isLoading = false;
        _errorMessage = result;
      });

      return;
    }

    /// USER
    final user =
        SupabaseService.currentUser;

    if (user == null) {

      setState(() {
        _isLoading = false;
        _errorMessage =
            'User tidak ditemukan.';
      });

      return;
    }

    /// ROLE
    final role =
        await _controller.getUserRole(
      user.id,
    );

    if (!mounted) return;

    /// MENTOR
    if (role == 'mentor') {

      final cvStatus =
          await _controller
              .getMentorCvStatus(
        user.id,
      );

      if (!mounted) return;

      if (cvStatus == null) {

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mentor_cv',
          (_) => false,
        );

      } else if (cvStatus ==
          'approved') {

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mentor_landing',
          (_) => false,
        );

      } else {

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/mentor_cv',
          (_) => false,
        );
      }

    } else {

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/landing',
        (_) => false,
      );
    }

    setState(() {
      _isLoading = false;
    });
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

                decoration:
                    const BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.only(
                    topLeft:
                        Radius.circular(50),

                    topRight:
                        Radius.circular(50),
                  ),
                ),

                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(30),

                  child: Column(
                    children: [

                      const Text(
                        "Welcome Back",

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Log in to your registered account.",

                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// ERROR
                      if (_errorMessage != null)
                        _buildErrorBox(),

                      /// IDENTIFIER
                      _buildTextField(
                        "Email or Username",

                        Icons.person_outline,

                        controller:
                            _identifierController,
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      _buildTextField(
                        "Password",

                        Icons.lock_outline,

                        controller:
                            _passwordController,

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

  /// ================= ERROR =================
  Widget _buildErrorBox() {

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 20,
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
        ),

        textAlign: TextAlign.center,
      ),
    );
  }

  /// ================= BACK =================
  Widget _buildBackButton() {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
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
              Navigator.pop(context);
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
    required TextEditingController
        controller,
    bool isPassword = false,
  }) {

    return TextField(
      controller: controller,
      obscureText: isPassword,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide:
              const BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
    );
  }

  /// ================= REMEMBER =================
  Widget _buildForgotSection() {

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Row(
          children: [

            Checkbox(
              value: _rememberMe,

              shape: const CircleBorder(),

              onChanged: (val) {

                setState(() {
                  _rememberMe = val!;
                });
              },
            ),

            const Text(
              "Remember me",

              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),

        TextButton(
          onPressed: () {},

          child: const Text(
            "Forgot password?",

            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= LOGIN BUTTON =================
  Widget _buildLoginButton() {

    return Container(
      width: double.infinity,
      height: 55,

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),

        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFF8B5C5),
            Color(0xFFB5D8F7),
          ],
        ),
      ),

      child: ElevatedButton(
        onPressed:
            _isLoading ? null : _login,

        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.transparent,

          shadowColor:
              Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        child: _isLoading

            ? const CircularProgressIndicator(
                color: Colors.white,
              )

            : const Text(
                "Log In",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// ================= SIGNUP =================
  Widget _buildSignUpLink() {

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [

        const Text(
          "Don't have an account? ",
        ),

        GestureDetector(
          onTap: () {

            Navigator.pushNamed(
              context,
              '/register',
            );
          },

          child: const Text(
            "Sign Up",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}