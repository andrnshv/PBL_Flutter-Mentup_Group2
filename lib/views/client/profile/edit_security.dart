import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/client/security_controller.dart';
import '../../../models/client/security_model.dart';

import '../../auth/login_page.dart';
import 'email_pass.dart';
import 'fag_sup.dart';

class EditSecurityPage extends StatefulWidget {
  const EditSecurityPage({super.key});

  @override
  State<EditSecurityPage> createState() => _EditSecurityPageState();
}

class _EditSecurityPageState extends State<EditSecurityPage> {
  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color primaryBlue = const Color(0xFF6D92CB);
  final Color textDark = const Color(0xFF2D3436);

  // Nomor WhatsApp admin (format internasional tanpa + dan tanpa spasi)
  final String _adminWa = '6285108636167'; // ← ganti dengan nomor admin asli

  final SecurityController _controller = SecurityController();

  SecurityModel? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await _controller.getSecurityData();

    if (!mounted) return;

    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                _buildFullGradientBackground(),
                Column(
                  children: [
                    _buildCustomAppBar(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 30,
                            ),
                            child: Column(
                              children: [
                                _buildSectionTitle("SECURITY"),
                                _buildMenuCard([
                                  _buildMenuTile(
                                    icon: Icons.lock_person_outlined,
                                    iconColor: primaryPurple,
                                    title: "Change Password",
                                    desc: "Update your security regularly",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ChangePasswordPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _buildMenuTile(
                                    icon: Icons.alternate_email_rounded,
                                    iconColor: primaryBlue,
                                    title: "Update Email",
                                    desc: userData?.email ?? "-",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const UpdateEmailPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                                const SizedBox(height: 25),
                                _buildSectionTitle("PREFERENCES"),
                                _buildMenuCard([
                                  _buildMenuTile(
                                    icon: Icons.support_agent_rounded,
                                    iconColor: const Color(0xFF1ABC9C),
                                    title: "Help Center",
                                    desc: "Contact support & info",
                                    onTap: () => _showHelpCenterPopOut(context),
                                  ),
                                  _buildDivider(),
                                  _buildMenuTile(
                                    icon: Icons.help_outline_rounded,
                                    iconColor: const Color(0xFFF39C12),
                                    title: "FAQ & Support",
                                    desc: "Find answers or contact us",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const FaqSupPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ]),
                                const SizedBox(height: 25),
                                _buildSectionTitle("ACCOUNT"),
                                _buildMenuCard([
                                  _buildMenuTile(
                                    icon: Icons.logout_rounded,
                                    iconColor: Colors.redAccent,
                                    title: "Sign Out",
                                    titleColor: Colors.redAccent,
                                    desc: "Log Out from your account",
                                    onTap: () => _showLogoutDialog(context),
                                  ),
                                  _buildDivider(),
                                  _buildMenuTile(
                                    icon: Icons.delete_outline_rounded,
                                    iconColor: Colors.redAccent,
                                    title: "Delete Account",
                                    titleColor: Colors.redAccent,
                                    desc: "Permanent action",
                                    onTap: () => _showConfirmPopOut(
                                      context,
                                      "Delete Account",
                                      "This action is permanent.",
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildFullGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFCDB4DB),
            Color(0xFFA7C7E7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: LinePatternPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "Settings",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: primaryPurple.withValues(alpha: 0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.05),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? desc,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: titleColor ?? textDark,
        ),
      ),
      subtitle: desc != null
          ? Text(
              desc,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[500],
                fontSize: 11,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.05),
      indent: 65,
      endIndent: 15,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          "Sign Out",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          "Are you sure you want to sign out?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterPopOut(BuildContext context) {
    Future<void> _hubungiAdmin(String pesan) async {
      final url = Uri.parse(
          'https://wa.me/$_adminWa?text=${Uri.encodeComponent(pesan)}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak bisa membuka WhatsApp')),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Help Center",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Need help with MentUp? Contact our team:",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildSupportTile(
              Icons.chat_rounded,
              "WhatsApp Support",
              "+62 851-0863-6167",
              onTap: () {
                Navigator.pop(context);
                _hubungiAdmin(
                  "Halo admin MentUp, saya butuh bantuan terkait aplikasi.",
                );
              },
            ),
            _buildSupportTile(
              Icons.account_balance_wallet_rounded,
              "Ajukan Refund",
              "Hubungi admin untuk proses refund",
              onTap: () {
                Navigator.pop(context);
                _hubungiAdmin(
                  "Halo admin MentUp, saya ingin mengajukan refund untuk "
                  "booking saya. Berikut detailnya:\n"
                  "- Nama: \n"
                  "- Tanggal sesi: \n"
                  "- Mentor: \n"
                  "- Alasan: ",
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    IconData icon,
    String title,
    String val, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: primaryPurple,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        val,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: onTap != null
          ? const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey)
          : null,
    );
  }

  void _showConfirmPopOut(
    BuildContext context,
    String title,
    String msg,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LinePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
