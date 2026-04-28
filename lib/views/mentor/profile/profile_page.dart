import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'dart:typed_data';

class MentorMainProfilePage extends StatefulWidget {
  const MentorMainProfilePage({super.key});

  @override
  State<MentorMainProfilePage> createState() => _MentorMainProfilePageState();
}

class _MentorMainProfilePageState extends State<MentorMainProfilePage> {
  // Tambahkan 3 variabel ini (isi dengan teks bawaan kamu)
  String name = "Lovie Jechonia";
  String username = "@loviejechonia";
  String headline = "Data Analyst";
  String bio =
      "\"Just a data analyst who loves making statistics easier to understand and helping others improve their English skills.";
  // TAMBAHKAN 2 VARIABEL INI:
  String phone = "08123456789";
  String address = "Kota Malang";

  // VARIABEL BARU UNTUK NAMPUNG FOTO BARU
  Uint8List? profileImageBytes;

  String? cvFileName;
  Uint8List? cvDocumentBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderProfile(context), // Header diperbarui dengan gradasi
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
                      _buildMenuItem(
                        context,
                        Icons.history_edu_rounded,
                        "History Session",
                        "Completed classes",
                        const Color(0xFFA7C7E7),
                        AppRoutes.historySession,
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
                  // --- TAMBAHKAN SECTION REPUTATION DI SINI ---
                  _buildMenuSection(
                    title: "Reputation",
                    items: [
                      _buildMenuItem(
                        context,
                        Icons.star_rounded,
                        "Client Reviews",
                        "See what they said about your class!",
                        const Color(
                          0xFFE9C46A,
                        ), // Warna Gold Muted (50% intensity)
                        "/reviews_page", // Ganti dengan rute ulasanmu nanti
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
                        // TAMBAHKAN ONTAP INI:
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                            arguments: {
                              'name': name,
                              'username': username,
                              'headline': headline,
                              'bio': bio,
                              'phone': phone,
                              'address': address,
                              'imageBytes': profileImageBytes,
                              'cvFileName':
                                  cvFileName, // Kirim CV yang ada sekarang
                              'cvDocumentBytes': cvDocumentBytes,
                            },
                          );

                          // Cek di DEBUG CONSOLE VS Code saat kamu klik Save!
                          print("Data dari halaman Edit: $result");

                          if (result != null &&
                              result is Map<String, dynamic>) {
                            setState(() {
                              name = result['name'] ?? name;
                              username = result['username'] ?? username;
                              headline = result['headline'] ?? headline;
                              bio = result['bio'] ?? bio;
                              phone =
                                  result['phone'] ??
                                  phone; // <--- Tambahkan ini
                              address = result['address'] ?? address;
                              profileImageBytes = result['imageBytes'];
                              cvFileName =
                                  result['cvFileName']; // Terima CV baru
                              cvDocumentBytes = result['cvDocumentBytes'];
                            });
                          }
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
      decoration: const BoxDecoration(
        // GRADIENT BACKGROUND: Selaras dengan Home Page
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
                onPressed: () => Navigator.pop(context), // Tombol Back Putih
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
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: profileImageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(profileImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/mentor.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF5B62CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // UBAH JADI INI:
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            username,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            headline,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // CAPTION BIO: Menambahkan personal touch sesuai contoh
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              bio,
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
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
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
