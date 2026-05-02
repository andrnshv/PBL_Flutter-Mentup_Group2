import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/mentor_model.dart';
import 'booking_page.dart';

class MentorProfilePage extends StatelessWidget {
  final MentorModel mentor;

  const MentorProfilePage({super.key, required this.mentor});

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Done":
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

    final bool isAvailable = true;

    final schedules = [
      {
        "date": "20 April 2026",
        "time": "13:00",
        "method": "Offline",
        "status": "Accepted"
      },
      {
        "date": "25 April 2026",
        "time": "10:00",
        "method": "Offline",
        "status": "Pending"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ================= HEADER =================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.7)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                /// ================= AVATAR + STATUS =================
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(mentor.image),
                            ),
                          ),

                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            /// ================= NAME =================
            Text(
              mentor.name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(mentor.category, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 6),

            /// ================= RATING + AVAILABILITY =================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(mentor.rating.toString()),

                const SizedBox(width: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? "Available" : "Unavailable",
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
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
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAvailable 
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingPage(mentor: mentor),
                            ),
                          );
                        } 
                      : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                          ? const Color(0xFF6C63FF) : const Color(0xFFE0E0E0),
                        foregroundColor: 
                            isAvailable ? Colors.white : Colors.grey.shade600,
                        elevation: isAvailable ? 3 : 0,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAvailable ? Icons.calendar_month : Icons.block,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAvailable ? "Book Session" : "Not Available",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

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
                  "Mentor profesional di bidang ${mentor.category}. Siap membantu kamu berkembang 🚀",
            ),

            /// ================= REVIEWS =================
            _section(
              title: "Reviews",
              content:
                  "⭐ 4.8 (120 reviews)\n\nMentor sangat membantu dan komunikatif!",
            ),

            /// ================= JADWAL =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mentoring Schedule",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    if (schedules.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.event_busy,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No schedule yet",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      ...schedules.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  color: Colors.purple),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${item["date"]} • ${item["time"]}"),
                                    Text(
                                      item["method"]!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                          item["status"]!)
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item["status"]!,
                                  style: TextStyle(
                                    color: getStatusColor(
                                        item["status"]!),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _section({required String title, required String content}) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(content),
          ],
        ),
      ),
    );
  }
}