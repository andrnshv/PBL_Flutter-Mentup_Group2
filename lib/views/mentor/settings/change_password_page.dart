import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // Colors - Menggunakan warna yang kamu minta
  final Color gradientPink = const Color(0xFFF8B5C5);
  final Color gradientBlue = const Color(0xFFB5D8F7);
  final Color primaryPurple = const Color(
    0xFF7E7BB9,
  ); // Tetap untuk aksen icon/teks
  final Color bgGray = const Color(0xFFF8F9FB);

  // Controllers
  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  // States
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _hasMinLength = false;
  bool _hasUpperLower = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(() {
      final text = _newPassCtrl.text;
      setState(() {
        _hasMinLength = text.length >= 8;
        _hasUpperLower =
            text.contains(RegExp(r'[A-Z]')) && text.contains(RegExp(r'[a-z]'));
        _hasNumber = text.contains(RegExp(r'[0-9]'));
      });
    });
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // --- BACKGROUND GRADASI PINK-BLUE ---
          _buildBackground(),

          Column(
            children: [
              _buildAppBar(context),

              // Spasi fleksibel agar kotak berada di posisi yang pas
              const Spacer(flex: 1),

              // --- FLOATING CARD RAMPING ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Biar tinggi kotak pas dengan isinya
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Set New Password",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: Color(0xFF7E7BB9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Keep your account safe by creating a strong password.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          _buildTextField(
                            "Current Password",
                            _oldPassCtrl,
                            _obscureOld,
                            () => setState(() => _obscureOld = !_obscureOld),
                            (val) => val!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(
                            "New Password",
                            _newPassCtrl,
                            _obscureNew,
                            () => setState(() => _obscureNew = !_obscureNew),
                            (val) {
                              if (val!.isEmpty) return "Required";
                              if (!_hasMinLength ||
                                  !_hasUpperLower ||
                                  !_hasNumber)
                                return "Insecure password";
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),
                          _buildCriteriaBox(),
                          const SizedBox(height: 15),

                          _buildTextField(
                            "Confirm Password",
                            _confirmPassCtrl,
                            _obscureConfirm,
                            () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            (val) => val != _newPassCtrl.text
                                ? "Not matching"
                                : null,
                          ),

                          const SizedBox(height: 30),
                          _buildUpdateButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientPink, gradientBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Hint kuning tipis di pojok agar gradasinya tidak membosankan
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD166).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: LinePatternPainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "Security Settings",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: primaryPurple,
          size: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.grey[400],
            size: 18,
          ),
          onPressed: toggle,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildCriteriaBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _criteriaItem("At least 8 characters", _hasMinLength),
          const SizedBox(height: 5),
          _criteriaItem("Uppercase & Lowercase", _hasUpperLower),
          const SizedBox(height: 5),
          _criteriaItem("Include numbers", _hasNumber),
        ],
      ),
    );
  }

  Widget _criteriaItem(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: met ? const Color(0xFF1ABC9C) : Colors.grey[400],
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            color: met ? Colors.black87 : Colors.grey[500],
            fontWeight: met ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [gradientPink, gradientBlue]),
        boxShadow: [
          BoxShadow(
            color: gradientPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }
}

class LinePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
