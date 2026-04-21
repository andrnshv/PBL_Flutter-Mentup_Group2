import 'package:flutter/material.dart';

// AUTH (GLOBAL)
import 'views/auth/welcome_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';

// CLIENT
import 'views/client/home/landing_page.dart';
import 'views/client/map/map_page.dart';
import 'views/client/search/search_page.dart';
import 'views/client/network/network_page.dart';
import 'views/client/profile/profile_page.dart';

// ROUTES
import 'routes/app_routes.dart';

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

      initialRoute: AppRoutes.welcome,

      routes: {
        AppRoutes.welcome: (_) => const WelcomePage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),

        AppRoutes.landing: (_) => const LandingPage(),
        AppRoutes.map: (_) => const MapPage(),
        AppRoutes.search: (_) => const SearchPage(),
        AppRoutes.network: (_) => const NetworkPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      },
    );
  }
}