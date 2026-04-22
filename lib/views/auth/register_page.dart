import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String selectedRole = 'Client';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur agar konten tidak terdorong saat keyboard muncul
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

            // Mendorong konten di bawahnya ke paling dasar
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
                  top: 30,
                  left: 30,
                  right: 30,
                  bottom: 20,
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

                    // --- FORM INPUT ---
                    // Menggunakan Container agar SingleChildScrollView tidak bentrok dengan Column utama
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height *
                            0.4, // Batasi tinggi form
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTextField("Full Name", Icons.person_outline),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Email Address",
                              Icons.email_outlined,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Username",
                              Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Password",
                              Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              "Confirm Password",
                              Icons.lock_reset_outlined,
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // --- PILIHAN ROLE DENGAN JARAK DI MASING-MASING SISI ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ), // Memberi jarak di sisi kiri & kanan
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Mendorong item ke ujung kiri & kanan padding
                        children: [
                          _buildRoleRadio("Client"),
                          _buildRoleRadio("Mentor"),
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

  // Fungsi baru untuk membuat Radio Button Lingkaran Biru
  Widget _buildRoleRadio(String role) {
    return GestureDetector(
      // Biar kalau teksnya diklik, lingkarannya juga ikut terpilih
      onTap: () => setState(() => selectedRole = role),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: role,
            groupValue:
                selectedRole, // Variabel state yang menyimpan pilihan saat ini
            activeColor: Colors.blue, // Warna titik lingkaran saat dipilih
            onChanged: (String? value) {
              setState(() {
                selectedRole = value!;
              });
            },
          ),
          Text(
            role,
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
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        // TAMBAHKAN BARIS INI:
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
        onPressed: () {
          // LOGIKA NAVIGASI BERDASARKAN ROLE
          if (selectedRole == 'Client') {
            Navigator.pushNamed(context, '/landing');
          } else {
            Navigator.pushNamed(context, '/mentor_landing');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
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
