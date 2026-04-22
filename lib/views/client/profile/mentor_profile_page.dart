import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/user_model.dart';

class MentorProfilePage extends StatelessWidget {
  final UserModel mentor;

  const MentorProfilePage({super.key, required this.mentor});

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Diterima":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      case "Selesai":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void openWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF6C63FF);

    final sessionList = [
      {"title": "UI/UX Mentoring", "status": "Pending"},
      {"title": "Flutter Session", "status": "Diterima"},
      {"title": "Backend API", "status": "Ditolak"},
      {"title": "Career Talk", "status": "Selesai"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ================= HEADER =================
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.6)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),

                Positioned(
                  top: 60,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(mentor.image),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Text(
              mentor.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(mentor.role, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(mentor.rating.toString()),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        openWhatsApp("6281234567890");
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("Message"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                      ),
                      onPressed: () {},
                      child: const Text("Book Session"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= QUICK INFO =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem("Experience", "5+ Years"),
                  _infoItem("Price", "Rp ${mentor.price}"),
                  _infoItem("Distance", "${mentor.distance} km"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= ABOUT =================
            _section(
              title: "About",
              content:
                  "Mentor profesional di bidang ${mentor.role}. Siap membantu kamu berkembang 🚀",
            ),

            /// ================= REVIEW =================
            _section(
              title: "Reviews",
              content: "Belum ada review.",
            ),

            /// ================= SESSION STATUS =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Session Status",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  ...sessionList.map((session) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(session["title"]!),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: getStatusColor(session["status"]!)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              session["status"]!,
                              style: TextStyle(
                                color:
                                    getStatusColor(session["status"]!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INFO ITEM
  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  /// SECTION
  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(content),
          ],
        ),
      ),
    );
  }
}