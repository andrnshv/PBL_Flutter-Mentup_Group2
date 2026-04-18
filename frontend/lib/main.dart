import 'package:flutter/material.dart';
import 'package:flutter_mentup/pages/landing.dart';
import 'pages/login.dart';
import 'pages/map_page.dart';

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
        '/': (context) => const LoginPage(),
        '/landing' : (context) => const LandingPage(),
        '/map': (context) => const MapPage(),
      },
    );
  }
}
