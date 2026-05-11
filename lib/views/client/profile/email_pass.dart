import 'package:flutter/material.dart';

/// ================= CHANGE PASSWORD =================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final Color primaryPurple =
      const Color(0xFF7E7BB9);

  final Color primaryBlue =
      const Color(0xFF6D92CB);

  final Color bgGray =
      const Color(0xFFF8F9FB);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPassController =
      TextEditingController();

  final TextEditingController newPassController =
      TextEditingController();

  final TextEditingController confirmPassController =
      TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;

  void checkPassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasUppercase =
          value.contains(RegExp(r'[A-Z]'));
      hasNumber =
          value.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return _baseLayout(
      context,
      title: "Change Password",
      icon: Icons.lock_reset_rounded,

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// ===== HEADER =====

            Center(
              child: Column(
                children: [

                  Container(
                    padding:
                        const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryPurple,
                          primaryBlue,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Create Strong Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Protect your account with a secure password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            /// ===== OLD PASSWORD =====

            _buildPasswordField(
              controller: oldPassController,
              hint: "Current Password",
              icon: Icons.lock_outline,
              isVisible: showOld,
              toggle: () {
                setState(() {
                  showOld = !showOld;
                });
              },
            ),

            const SizedBox(height: 18),

            /// ===== NEW PASSWORD =====

            _buildPasswordField(
              controller: newPassController,
              hint: "New Password",
              icon: Icons.password_rounded,
              isVisible: showNew,

              onChanged: checkPassword,

              toggle: () {
                setState(() {
                  showNew = !showNew;
                });
              },
            ),

            const SizedBox(height: 18),

            /// ===== PASSWORD REQUIREMENTS =====

            Container(
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    primaryPurple.withValues(alpha: 0.06),

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Password Requirements",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _requirement(
                    "Minimum 8 characters",
                    hasMinLength,
                  ),

                  _requirement(
                    "Contains uppercase letter",
                    hasUppercase,
                  ),

                  _requirement(
                    "Contains number",
                    hasNumber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ===== CONFIRM PASSWORD =====

            _buildPasswordField(
              controller:
                  confirmPassController,

              hint: "Confirm New Password",

              icon: Icons.verified_user_rounded,

              isVisible: showConfirm,

              isConfirm: true,

              toggle: () {
                setState(() {
                  showConfirm =
                      !showConfirm;
                });
              },
            ),

            const SizedBox(height: 35),

            /// ===== BUTTON =====

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  elevation: 0,

                  backgroundColor:
                      primaryPurple,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                ),

                onPressed: _submit,

                child: const Text(
                  "Save Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requirement(
      String text, bool valid) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),

      child: Row(
        children: [

          Icon(
            valid
                ? Icons.check_circle
                : Icons.radio_button_unchecked,

            color: valid
                ? Colors.green
                : Colors.grey,

            size: 18,
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: TextStyle(
              color: valid
                  ? Colors.green
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isVisible,
    required VoidCallback toggle,
    bool isConfirm = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,

      obscureText: !isVisible,

      onChanged: onChanged,

      validator: (value) {

        if (value == null || value.isEmpty) {
          return "Field cannot be empty";
        }

        if (!isConfirm) {

          if (value.length < 8) {
            return "Minimum 8 characters";
          }

          if (!value.contains(
              RegExp(r'[A-Z]'))) {
            return "Need uppercase letter";
          }

          if (!value.contains(
              RegExp(r'[0-9]'))) {
            return "Need number";
          }
        }

        if (isConfirm &&
            value !=
                newPassController.text) {
          return "Password not match";
        }

        return null;
      },

      decoration: _inputDecoration(
        hint,
        icon,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!
        .validate()) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Password Updated!"),
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(
      String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,

      prefixIcon:
          Icon(icon, color: primaryPurple),

      filled: true,
      fillColor: bgGray,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/// ================= UPDATE EMAIL =================

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() =>
      _UpdateEmailPageState();
}

class _UpdateEmailPageState
    extends State<UpdateEmailPage> {

  final Color primaryPurple =
      const Color(0xFF7E7BB9);

  final Color primaryBlue =
      const Color(0xFF6D92CB);

  final Color bgGray =
      const Color(0xFFF8F9FB);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldEmailController =
      TextEditingController();

  final TextEditingController newEmailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return _baseLayout(
      context,
      title: "Update Email",
      icon: Icons.alternate_email_rounded,

      child: Form(
        key: _formKey,

        child: Column(
          children: [

            /// ===== ICON =====

            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryPurple,
                    primaryBlue,
                  ],
                ),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.email_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Update Your Email",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Enter your old email and new email",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 35),

            /// ===== OLD EMAIL =====

            TextFormField(
              controller:
                  oldEmailController,

              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Old email required";
                }

                return null;
              },

              decoration: _inputDecoration(
                "Current Email",
                Icons.mail_outline,
              ),
            ),

            const SizedBox(height: 18),

            /// ===== NEW EMAIL =====

            TextFormField(
              controller:
                  newEmailController,

              validator: (value) {

                if (value == null ||
                    value.isEmpty) {
                  return "New email required";
                }

                if (!value.contains("@")) {
                  return "Invalid email";
                }

                return null;
              },

              decoration: _inputDecoration(
                "New Email",
                Icons.mark_email_read_rounded,
              ),
            ),

            const SizedBox(height: 18),

            /// ===== PASSWORD =====

            TextFormField(
              controller:
                  passwordController,

              obscureText: !showPassword,

              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return "Password required";
                }

                return null;
              },

              decoration: _inputDecoration(
                "Enter Password",
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),

                  onPressed: () {
                    setState(() {
                      showPassword =
                          !showPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 35),

            /// ===== BUTTON =====

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  elevation: 0,

                  backgroundColor:
                      primaryPurple,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                ),

                onPressed: _submit,

                child: const Text(
                  "Save Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!
        .validate()) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Email Updated!"),
        ),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(
      String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,

      prefixIcon:
          Icon(icon, color: primaryPurple),

      filled: true,
      fillColor: bgGray,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

/// ================= BASE LAYOUT =================

Widget _baseLayout(
  BuildContext context, {
  required String title,
  required Widget child,
  required IconData icon,
}) {
  return Scaffold(
    body: Stack(
      children: [

        /// ===== BACKGROUND =====

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFCDB4DB),
                Color(0xFFA7C7E7),
              ],

              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        /// ===== CONTENT =====

        Column(
          children: [

            /// ===== APPBAR =====

            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),

                child: Row(
                  children: [

                    IconButton(
                      icon: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          title,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            /// ===== CARD =====

            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  35,
                ),

                padding:
                    const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          35),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),

                      blurRadius: 20,
                      offset:
                          const Offset(0, 10),
                    ),
                  ],
                ),

                child:
                    SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  child: child,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}