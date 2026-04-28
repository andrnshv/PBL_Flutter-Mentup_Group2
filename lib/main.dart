import 'package:flutter/material.dart';
import 'package:flutter_mentup/views/client/profile/mentor_profile_page.dart';
import 'package:flutter_mentup/views/mentor/booking/booking_detail_page.dart';
import 'package:flutter_mentup/views/mentor/booking/booking_request_page.dart';
import 'package:flutter_mentup/views/mentor/home/article_page.dart';

// AUTH (GLOBAL)
import 'views/auth/welcome_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/auth/cv_upload.dart';

// CLIENT
import 'views/client/home/home_page.dart';
import 'views/client/map/map_page.dart';
import 'views/client/search/search_page.dart';
import 'views/client/History/History_page.dart';
import 'views/client/profile/profile_page.dart';

// MENTOR
import 'views/mentor/home/landing_page.dart';
import 'views/mentor/profile/profile_page.dart';
import 'views/mentor/profile/edit_profile_page.dart';

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
        // AUTH
        AppRoutes.welcome: (_) => const WelcomePage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),

        AppRoutes.landing: (_) => const HomePage(),

        AppRoutes.map: (_) => const MapPage(),
        AppRoutes.search: (_) => const SearchPage(),
        AppRoutes.network: (_) => const HistoryPage(),
        AppRoutes.profile: (_) => const ProfilePage(),

        // MENTOR
        AppRoutes.mentorCV: (_) => const MentorCvUploadPage(),
        AppRoutes.mentorLanding: (_) => const MentorLandingPage(),
        AppRoutes.mentorTips: (_) => const ArticlePage(),
        AppRoutes.bookingRequest: (_) => const BookingRequestPage(),
        AppRoutes.bookingDetail: (_) => const BookingDetailPage(),

        AppRoutes.mentorProfile: (_) => const MentorMainProfilePage(),
        AppRoutes.editProfile: (_) => const EditProfilePage(),
        AppRoutes.editRates: (_) =>
            const Scaffold(body: Center(child: Text("Edit My Fee"))),
        AppRoutes.mySchedule: (_) =>
            const Scaffold(body: Center(child: Text("My Schedule"))),
        AppRoutes.historySession: (_) =>
            const Scaffold(body: Center(child: Text("History Session"))),
        AppRoutes.transactions: (_) =>
            const Scaffold(body: Center(child: Text("Transactions"))),
        AppRoutes.teachingForm: (_) =>
            const Scaffold(body: Center(child: Text("Form Teaching Approval"))),
        AppRoutes.settingsAccount: (_) =>
            const Scaffold(body: Center(child: Text("Settings"))),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      },
    );
  }
}
