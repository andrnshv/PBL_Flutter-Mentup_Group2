// FLUTTER
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AUTH
import 'views/auth/welcome_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/auth/cv_upload.dart';

// CLIENT
import 'views/client/home/home_page.dart';
import 'views/client/home/client_verification_page.dart';
import 'views/client/map/map_page.dart';
import 'views/client/search/search_page.dart';
import 'views/client/History/History_page.dart';
import 'views/client/profile/profile_page.dart';

// MENTOR
import 'views/mentor/home/landing_page.dart';
import 'views/mentor/home/article_page.dart';
import 'views/mentor/profile/profile_page.dart';
import 'views/mentor/profile/edit_profile_page.dart';
import 'views/mentor/settings/settings_page.dart';
import 'views/mentor/settings/faq_page.dart';
import 'views/mentor/settings/change_password_page.dart';
import 'views/mentor/settings/change_email_page.dart';
import 'views/mentor/profile/service_rates_page.dart';
import 'views/mentor/schedule/my_schedule_page.dart';
import 'views/mentor/schedule/manage_slot_page.dart';
import 'views/mentor/booking/booking_detail_page.dart';
import 'views/mentor/booking/booking_request_page.dart';
import 'views/mentor/review/teaching_proof_page.dart';
import 'views/mentor/review/clients_review_page.dart';

// ROUTES
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

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

      // ================= ENTRY POINT =================
      home: const AuthChecker(),

      // ================= ROUTES =================
      routes: {
        // AUTH
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),

        // CLIENT
        AppRoutes.landing: (_) => const HomePage(),
        AppRoutes.map: (_) => const MapPage(),
        AppRoutes.search: (_) => const SearchPage(),
        AppRoutes.network: (_) => const HistoryPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.clientVerification: (_) =>
            const ClientVerificationPage(),

        // MENTOR
        AppRoutes.mentorCV: (_) => const MentorCvUploadPage(),
        AppRoutes.mentorLanding: (_) =>
            const MentorLandingPage(),
        AppRoutes.mentorTips: (_) => const ArticlePage(),
        AppRoutes.bookingRequest: (_) =>
            const BookingRequestPage(),
        AppRoutes.bookingDetail: (_) =>
            const BookingDetailPage(),

        AppRoutes.mentorProfile: (_) =>
            const MentorMainProfilePage(),

        AppRoutes.editProfile: (_) =>
            const EditProfilePage(),

        AppRoutes.editRates: (_) =>
            const ServiceRatesPage(),

        AppRoutes.mySchedule: (_) =>
            const MySchedulePage(),

        AppRoutes.manageSlot: (_) =>
            const ManageSlotPage(),

        AppRoutes.transactions: (_) => const Scaffold(
              body: Center(
                child: Text("Transactions"),
              ),
            ),

        AppRoutes.teachingForm: (_) =>
            const TeachingProofPage(),

        AppRoutes.clientReviews: (_) =>
            const ClientReviewsPage(),

        AppRoutes.settingsAccount: (_) =>
            const SettingsPage(),

        AppRoutes.faq: (_) => const FaqPage(),

        AppRoutes.changePassword: (_) =>
            const ChangePasswordPage(),

        AppRoutes.changeEmail: (_) =>
            const ChangeEmailPage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        );
      },
    );
  }
}

// ================= AUTH CHECKER =================

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final supabase = Supabase.instance.client;

  bool loading = true;

  Widget currentPage = const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    try {
      final session = supabase.auth.currentSession;

      // ================= BELUM LOGIN =================
      if (session == null) {
        currentPage = const WelcomePage();

        setState(() {
          loading = false;
        });

        return;
      }

      final uid = session.user.id;

      debugPrint("LOGIN UID = $uid");

      // ================= GET USER ROLE =================
      // IMPORTANT:
      // GANTI user_id JIKA NAMA KOLOM DATABASE BERBEDA
      final response = await supabase
          .from('appuser')
          .select('role')
          .eq('id', uid)
          .maybeSingle();

      debugPrint("ROLE RESPONSE = $response");

      // ================= USER TIDAK DITEMUKAN =================
      if (response == null) {
        await supabase.auth.signOut();

        currentPage = const WelcomePage();

        setState(() {
          loading = false;
        });

        return;
      }

      final role = response['role'];

      debugPrint("ROLE = $role");

      // ================= MENTOR =================
      if (role == 'mentor') {
        currentPage = const MentorLandingPage();
      }

      // ================= CLIENT =================
      else if (role == 'client') {
        currentPage = const HomePage();
      }

      // ================= ROLE TIDAK VALID =================
      else {
        await supabase.auth.signOut();

        currentPage = const WelcomePage();
      }
    } catch (e) {
      debugPrint("AUTH ERROR = $e");

      currentPage = const WelcomePage();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return currentPage;
  }
}