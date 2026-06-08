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
import 'views/mentor/profile/service_rates_page.dart';
import 'views/mentor/schedule/my_schedule_page.dart';
import 'views/mentor/schedule/manage_slot_page.dart';
import 'views/mentor/booking/booking_detail_page.dart';
import 'views/mentor/booking/booking_request_page.dart';
import 'views/mentor/review/teaching_proof_page.dart';
import 'views/mentor/review/clients_review_page.dart';
import 'views/mentor/history/mentor_transactions_page.dart';

// ROUTES
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
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
      home: const AuthGate(),
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

        // MENTOR
        AppRoutes.mentorCV: (_) => const MentorCvUploadPage(),

        AppRoutes.mentorLanding: (_) => const MentorLandingPage(),

        AppRoutes.mentorTips: (_) => const ArticlePage(),

        AppRoutes.bookingRequest: (_) => const BookingRequestPage(),

        AppRoutes.bookingDetail: (_) => const BookingDetailPage(),

        AppRoutes.mentorProfile: (_) => const MentorMainProfilePage(),

        AppRoutes.editProfile: (_) => const EditProfilePage(),

        AppRoutes.editRates: (_) => const ServiceRatesPage(),

        AppRoutes.mySchedule: (_) => const MySchedulePage(),

        AppRoutes.manageSlot: (_) => const ManageSlotPage(),

        AppRoutes.transactions: (_) => const MentorTransactionsPage(),

        AppRoutes.teachingForm: (_) => const TeachingProofPage(),

        AppRoutes.clientReviews: (_) => const ClientReviewsPage(),

        AppRoutes.settingsAccount: (_) => const SettingsPage(),

        AppRoutes.faq: (_) => const FaqPage(),

        AppRoutes.changePassword: (_) => const ChangePasswordPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      },
    );
  }
}

// ================= AUTH GATE =================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;

  Widget currentPage = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();

    initAuth();
  }

  Future<void> initAuth() async {
    debugPrint("========== AUTH START ==========");

    try {
      // Delay supaya restore session selesai
      await Future.delayed(const Duration(seconds: 1));

      final session = supabase.auth.currentSession;

      debugPrint("SESSION = $session");

      // ================= SESSION NULL =================
      if (session == null) {
        debugPrint("STATUS = SESSION NULL");

        currentPage = const WelcomePage();

        setState(() {
          isLoading = false;
        });

        return;
      }

      final uid = session.user.id;

      debugPrint("USER ID = $uid");

      debugPrint("EMAIL = ${session.user.email}");

      // ================= QUERY DATABASE =================
      debugPrint("QUERY ROLE FROM DATABASE...");

      final response =
          await supabase.from('appuser').select().eq('id', uid).maybeSingle();

      debugPrint("DATABASE RESPONSE = $response");

      // ================= USER NOT FOUND =================
      if (response == null) {
        debugPrint("STATUS = USER NOT FOUND");

        currentPage = const WelcomePage();

        setState(() {
          isLoading = false;
        });

        return;
      }

      final role = response['role'];

      debugPrint("ROLE = $role");

      // ================= MENTOR =================
      if (role == 'mentor') {
        debugPrint("REDIRECT = MENTOR");

        currentPage = const MentorLandingPage();
      }
      // ================= CLIENT =================
      else if (role == 'klien') {
        debugPrint("REDIRECT = CLIENT");

        currentPage = const HomePage();
      }
      // ================= UNKNOWN ROLE =================
      else {
        debugPrint("STATUS = UNKNOWN ROLE");

        currentPage = const WelcomePage();
      }
    } catch (e, stack) {
      debugPrint("========== AUTH ERROR ==========");

      debugPrint("$e");

      debugPrint("$stack");

      currentPage = const WelcomePage();
    }

    debugPrint("========== AUTH END ==========");

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return currentPage;
  }
}
