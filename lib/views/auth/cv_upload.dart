import 'package:flutter/material.dart';

class MentorCvUploadPage extends StatefulWidget {
  const MentorCvUploadPage({super.key});

  @override
  State<MentorCvUploadPage> createState() => _MentorCvUploadPageState();
}

class _MentorCvUploadPageState extends State<MentorCvUploadPage> {
  // 1. Variabel penanda apakah CV sudah disubmit atau belum
  bool isSubmitted = false;

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
            // Tombol back disembunyikan jika sudah disubmit agar user tidak iseng kembali
            if (!isSubmitted) _buildBackButton(),

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2. LOGIKA IF-ELSE TAMPILAN
                    // Jika BELUM disubmit, tampilkan form upload
                    if (!isSubmitted) ...[
                      const Text(
                        "Hello Mentor!",
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

                      // KOTAK UPLOAD
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 50,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "Drop or click here to upload your resume.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "The format supported is PDF",
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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

                      // Tombol Sign Up yang akan mengubah state
                      _buildSignUpFinalButton(),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
                    ]
                    // Jika SUDAH disubmit, tampilkan pesan menunggu
                    else ...[
                      const Icon(
                        Icons.access_time_filled, // Ikon jam
                        color: Color(0xFFA7C7E7), // Warna biru senada tema
                        size: 90,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Please Wait...",
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

                      // Tombol untuk kembali ke halaman login
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

  // --- WIDGET HELPER ---

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

  Widget _buildSignUpFinalButton() {
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
        onPressed: () {
          // 3. MENGUBAH STATE menjadi TRUE saat tombol diklik
          setState(() {
            isSubmitted = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
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
          '/mentor_landing',
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
