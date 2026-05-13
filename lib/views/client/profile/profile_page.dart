import 'package:flutter/material.dart';

import '../../../controller/clien/profile_controller.dart';
import '../../../models/clien/profile_model.dart';
import '../../../routes/app_routes.dart';

import 'edit_profile_page.dart';
import 'edit_security.dart';
import 'my_mentors_page.dart';
import 'payment_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  final ProfileController _controller =
      ProfileController();

  ProfileModel? _profile;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile =
        await _controller.loadProfileData();

    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FB),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [

                  _buildHeader(),

                  const SizedBox(height: 20),

                  _buildStats(),

                  const SizedBox(height: 20),

                  _buildMenuSection(
                    title: "Account",
                    items: [

                      _buildMenuItem(
                        Icons.person,
                        "Edit Profile",
                        "Update your personal info",
                        Colors.deepPurple,
                        () async {

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfilePage(),
                            ),
                          );

                          _loadProfile();
                        },
                      ),

                      _buildMenuItem(
                        Icons.lock,
                        "Security",
                        "Password & privacy",
                        Colors.grey,
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EditSecurityPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _buildMenuSection(
                    title: "Social",
                    items: [

                      _buildMenuItem(
                        Icons.people,
                        "My Mentors",
                        "Your active & past mentors",
                        const Color(0xFF90DBF4),
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MyMentorsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _buildMenuSection(
                    title:
                        "Payment & Billing",

                    items: [

                      _buildMenuItem(
                        Icons.credit_card,
                        "Payments",
                        "History, methods & invoices",
                        const Color(0xFFB5E48C),
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaymentPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  _buildMenuSection(
                    title: "Account Action",
                    items: [

                      _buildMenuItem(
                        Icons.logout_rounded,
                        "Sign Out",
                        "Logout from your account",
                        Colors.redAccent,
                        () {
                          _showLogoutDialog();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  /// HEADER
  Widget _buildHeader() {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        24,
        50,
        24,
        30,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB993D6),
            Color(0xFF8CA6DB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight:
              Radius.circular(35),
        ),
      ),

      child: Column(
        children: [

          CircleAvatar(
            radius: 50,

            backgroundColor:
                Colors.white24,

            backgroundImage:
                _profile?.fotoUrl != null &&
                        _profile!
                            .fotoUrl!
                            .isNotEmpty
                    ? NetworkImage(
                        _profile!.fotoUrl!,
                      )
                    : null,

            child:
                _profile?.fotoUrl == null ||
                        _profile!
                            .fotoUrl!
                            .isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
          ),

          const SizedBox(height: 12),

          Text(
            _profile?.namaLengkap ?? 'User',

            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            _profile?.username != null
                ? '@${_profile!.username}'
                : '',

            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.15),

              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Text(
              _profile?.bio ??
                  'No bio yet.',

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STATS
  Widget _buildStats() {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.03),
              blurRadius: 10,
            ),
          ],
        ),

        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            _StatItem(
              title: "Sessions",
              value: "24",
            ),

            _StatItem(
              title: "Mentors",
              value: "5",
            ),

            _StatItem(
              title: "Progress",
              value: "80%",
            ),
          ],
        ),
      ),
    );
  }

  /// MENU SECTION
  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 10,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  /// MENU ITEM
  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subTitle,
    Color color,
    VoidCallback onTap,
  ) {

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color:
              color.withValues(alpha: 0.1),

          borderRadius:
              BorderRadius.circular(10),
        ),

        child: Icon(
          icon,
          color: color,
        ),
      ),

      title: Text(
        title,

        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      subtitle: Text(subTitle),

      trailing:
          const Icon(Icons.chevron_right),

      onTap: onTap,
    );
  }

  /// LOGOUT DIALOG
  void _showLogoutDialog() {

    showModalBottomSheet(
      context: context,

      backgroundColor:
          Colors.transparent,

      builder: (context) {

        return Container(
          padding:
              const EdgeInsets.all(30),

          decoration:
              const BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              Container(
                width: 40,
                height: 4,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Icon(
                Icons.logout_rounded,
                size: 45,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 15),

              const Text(
                "Sign Out",

                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Are you sure you want to logout from your account?",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      style:
                          OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),

                      child: const Text(
                        "Cancel",
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {

                        Navigator.pop(
                          context,
                        );

                        await _controller
                            .signOut();

                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (_) => false,
                        );
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),

                      child: const Text(
                        "Sign Out",

                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {

  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Text(
          value,

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,

          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}