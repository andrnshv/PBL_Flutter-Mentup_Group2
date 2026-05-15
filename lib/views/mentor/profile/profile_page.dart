import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../controller/mentor/profile_controller.dart';
import '../../../models/mentor/profile_model.dart';

class MentorMainProfilePage extends StatefulWidget {
  const MentorMainProfilePage({super.key});

  @override
  State<MentorMainProfilePage> createState() => _MentorMainProfilePageState();
}

class _MentorMainProfilePageState extends State<MentorMainProfilePage> {
  final MentorProfileController _controller = MentorProfileController();


  MentorProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

Future<void> _loadProfile() async {
  final profile = await _controller.getProfile();
  debugPrint('PROFILE RESULT: $profile'); // <-- tambah ini
  debugPrint('NAMA: ${profile?.namaLengkap}');
  debugPrint('USERNAME: ${profile?.username}');
  debugPrint('BIO: ${profile?.bio}');
  if (mounted) {
    setState(() {
      _profile  = profile;
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderProfile(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  _buildMenuSection(
                    title: "Class Management",
                    items: [
                      _buildMenuItem(
                        context,
                        Icons.calendar_month_rounded,
                        "My Schedule",
                        "Manage available slots",
                        const Color(0xFFCDB4DB),
                        AppRoutes.mySchedule,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.verified_user_rounded,
                        "Verify Booking",
                        "Check incoming requests",
                        const Color(0xFFF5B3CE),
                        AppRoutes.bookingRequest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildMenuSection(
                    title: "Financial & Documents",
                    items: [
                      _buildMenuItem(
                        context,
                        Icons.payments_rounded,
                        "Transactions",
                        "Earning history",
                        const Color(0xFFA7C7E7),
                        AppRoutes.transactions,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.price_change_rounded,
                        "Service Rates",
                        "Update hourly rate",
                        const Color(0xFFF5B3CE),
                        AppRoutes.editRates,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.assignment_turned_in_rounded,
                        "Teaching Proof",
                        "Fill teaching form",
                        const Color(0xFFCDB4DB),
                        AppRoutes.teachingForm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildMenuSection(
                    title: "Reputation",
                    items: [
                      _buildMenuItem(
                        context,
                        Icons.star_rounded,
                        "Client Reviews",
                        "See what they said about your class!",
                        const Color(0xFFE9C46A),
                        AppRoutes.clientReviews,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildMenuSection(
                    title: "Account Settings",
                    items: [
                      _buildMenuItem(
                        context,
                        Icons.person_outline_rounded,
                        "Edit Profile",
                        "Update photo & CV",
                        const Color(0xFF5B62CC),
                        AppRoutes.editProfile,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                          );
                          // Reload setelah kembali dari edit
                          _loadProfile();
                        },
                      ),
                      _buildMenuItem(
                        context,
                        Icons.settings_outlined,
                        "Security",
                        "Account & Password",
                        Colors.grey,
                        AppRoutes.settingsAccount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderProfile(BuildContext context) {
    final profile = _profile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCDB4DB), Color(0xFFA7C7E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          // FOTO PROFIL
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: profile?.fotoUrl != null && profile!.fotoUrl!.isNotEmpty
                  ? Image.network(
                      profile.fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/mentor.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset('assets/mentor.png', fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 12),

          // NAMA
          Text(
            profile?.namaLengkap.isNotEmpty == true
                ? profile!.namaLengkap
                : 'Mentor',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // USERNAME
          Text(
            profile?.username.isNotEmpty == true
                ? '@${profile!.username}'
                : '',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // CHIP UNIVERSITAS & KEAHLIAN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile?.universitas.isNotEmpty == true)
                _buildSmallInfoChip(
                  Icons.school_rounded,
                  profile!.universitas,
                ),
              if (profile?.universitas.isNotEmpty == true &&
                  profile?.keahlian.isNotEmpty == true)
                const SizedBox(width: 10),
              if (profile?.keahlian.isNotEmpty == true)
                _buildSmallInfoChip(
                  Icons.verified_user_rounded,
                  profile!.keahlian,
                ),
            ],
          ),

          const SizedBox(height: 15),

          // BIO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              profile?.bio.isNotEmpty == true
                  ? profile!.bio
                  : 'No bio yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subTitle,
    Color color,
    String route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subTitle,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () => Navigator.pushNamed(context, route),
    );
  }
}