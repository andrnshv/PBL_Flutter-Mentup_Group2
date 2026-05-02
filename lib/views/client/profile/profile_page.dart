import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Park Chanyeol";
  String username = "@chanyeol";
  String role = "Client • Music Enthusiast";
  String bio =
      "Loves learning music and improving vocal skills. Actively books sessions with mentors.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 20),

            /// SECTION ACCOUNT
            _buildMenuSection(
              title: "Account",
              items: [
                _buildMenuItem(
                  Icons.person,
                  "Edit Profile",
                  "Update your personal info",
                  Colors.deepPurple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.lock,
                  "Security",
                  "Password & privacy",
                  Colors.grey,
                  () {},
                ),
              ],
            ),

            /// SECTION ACTIVITY
            _buildMenuSection(
              title: "Activity",
              items: [
                _buildMenuItem(
                  Icons.calendar_today,
                  "Sessions",
                  "View your bookings",
                  const Color(0xFFA7C7E7),
                  () {},
                ),
                _buildMenuItem(
                  Icons.music_note,
                  "Practice History",
                  "Your learning progress",
                  const Color(0xFFF5B3CE),
                  () {},
                ),
              ],
            ),

            /// SECTION REPUTATION
            _buildMenuSection(
              title: "Reputation",
              items: [
                _buildMenuItem(
                  Icons.star_rounded,
                  "Mentor Reviews",
                  "View your review history for your mentor",
                  const Color(0xFFE9C46A),
                  () {
                    Navigator.pushNamed(context, "/reviews_page");
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

  /// ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
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
          /// PROFILE IMAGE
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          /// NAME
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 2),

          /// USERNAME (BARU)
          Text(
            username,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),

          /// ROLE
          Text(
            role,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          /// BIO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              bio,
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

  /// ================= STATS =================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(title: "Sessions", value: "24"),
            _StatItem(title: "Mentors", value: "5"),
            _StatItem(title: "Progress", value: "80%"),
          ],
        ),
      ),
    );
  }

  /// ================= MENU SECTION =================
  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  /// ================= MENU ITEM =================
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subTitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// ================= STAT ITEM =================
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}