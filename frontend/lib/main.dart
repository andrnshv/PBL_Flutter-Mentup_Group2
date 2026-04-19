import 'package:flutter/material.dart';
import 'package:flutter_mentup/pages/landing.dart';

import 'pages/welcome_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/map_page.dart';
import 'pages/search_page.dart';
import 'pages/network_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFD4B2F7),
      ),
      initialRoute: '/',
      routes: {
        // Ubah rute '/' agar membuka WelcomePage pertama kali
        '/': (context) => const WelcomePage(),

        // Pindahkan LoginPage ke rute spesifik '/login'
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/landing': (context) => const LandingPage(),
        '/map': (context) => const MapPage(),
        '/search': (context) => const SearchPage(),
        '/network': (context) => const NetworkPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
