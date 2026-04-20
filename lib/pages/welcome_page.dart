import 'dart:ui';
import 'package:flutter/material.dart';
import 'login.dart'; // Pastikan ini sesuai dengan nama file login kamu

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCDB4DB), // 0%
              Color(0xFFF5B3CE), // 50%
              Color(0xFFA7C7E7), // 100%
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Teks Welcome =)
              const Text(
                'Welcome =)',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w700,
                  fontSize: 55,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Ready to level up your skills today?\nLet’s find the perfect mentor for your goals!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // LOGO DARI ASSETS
              // PENTING: Ganti 'logo.png' dengan nama file logo yang ada di folder assets-mu!
              Image.asset(
                'assets/logo.png',
                width: 287,
                height: 287,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 2),

              // Tombol Create Account
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 47.0),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Log In (Glassmorphism)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 47.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
