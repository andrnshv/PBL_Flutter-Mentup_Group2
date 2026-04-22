import 'package:flutter/material.dart';

class MentorLandingPage extends StatelessWidget {
  const MentorLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Dashboard Mentor MentUp\n(Coming Soon)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}