import 'package:flutter/material.dart';

// ================= CHANGE PASSWORD =================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color bgGray = const Color(0xFFF8F9FB);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool showPassword = false;
  bool showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return _baseLayout(
      context,
      title: "Change Password",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              controller: passwordController,
              hint: "New Password",
              isVisible: showPassword,
              toggle: () => setState(() => showPassword = !showPassword),
            ),
            const SizedBox(height: 15),
            _buildPasswordField(
              controller: confirmController,
              hint: "Confirm Password",
              isVisible: showConfirm,
              toggle: () => setState(() => showConfirm = !showConfirm),
              isConfirm: true,
            ),
            const SizedBox(height: 30),
            _buildButton("Save Password"),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback toggle,
    bool isConfirm = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: (value) {
        if (value == null || value.isEmpty) return "Field cannot be empty";
        if (!isConfirm && value.length < 6) return "Min 6 characters";
        if (isConfirm && value != passwordController.text) {
          return "Password not match";
        }
        return null;
      },
      decoration: _inputDecoration(hint).copyWith(
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _submit,
        child: Text(text),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _showSuccess();
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password updated!")),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: bgGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ================= UPDATE EMAIL =================
class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color bgGray = const Color(0xFFF8F9FB);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _baseLayout(
      context,
      title: "Update Email",
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email required";
                }
                if (!value.contains("@")) {
                  return "Invalid email";
                }
                return null;
              },
              decoration: _inputDecoration("New Email"),
            ),
            const SizedBox(height: 30),
            _buildButton("Save Email"),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _submit,
        child: Text(text),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email updated!")),
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: bgGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ================= BASE LAYOUT (REUSABLE) =================
Widget _baseLayout(BuildContext context,
    {required String title, required Widget child}) {
  return Scaffold(
    body: Stack(
      children: [
        _buildBackground(),
        Column(
          children: [
            _buildAppBar(context, title),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: SingleChildScrollView(child: child),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ================= SHARED UI =================
Widget _buildBackground() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFCDB4DB), Color(0xFFA7C7E7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}

Widget _buildAppBar(BuildContext context, String title) {
  return SafeArea(
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}