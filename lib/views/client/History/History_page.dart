import 'package:flutter/material.dart';
import '../profile/mentor_profile_page.dart';
import '../../../models/mentor_model.dart';
import '../profile/booking_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedTab = 0;

  List<Map<String, dynamic>> historyMentors = [
    {
      "name": "Jerome",
      "role": "Matematika",
      "image": "assets/mentor1.jpg",
      "date": "12 April 2026",
      "dateObject": DateTime(2026, 4, 12),
      "status": "Done",
      "rating": 4,
      "review": "Mentor sangat membantu dan penjelasannya mudah dipahami!",
    },
    {
      "name": "Belva",
      "role": "UX Designer",
      "image": "assets/mentor2.jpg",
      "date": "10 April 2026",
      "dateObject": DateTime(2026, 4, 10),
      "status": "Done",
      "rating": 0,
      "review": null,
    },
    {
      "name": "Loey",
      "role": "Music",
      "image": "assets/profile.jpg",
      "date": "5 April 2026",
      "dateObject": DateTime(2026, 4, 5),
      "status": "Cancelled",
      "rating": 0,
      "review": null,
    },
  ];

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }

  /// ================= REVIEW POPUP =================
  void _showReviewSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 15),

            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(data["image"]),
            ),

            const SizedBox(height: 10),

            Text(
              data["name"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            _buildStars(data["rating"] ?? 0),

            const SizedBox(height: 15),

            Text(
              data["review"] ?? "No review yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List done =
        historyMentors.where((e) => e["status"] == "Done").toList();

    List cancelled = historyMentors.where(
      (e) =>
          e["status"] == "Cancelled" ||
          e["status"] == "Rescheduled",
    ).toList();

    List currentList = selectedTab == 0 ? done : cancelled;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8E7CFF)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Sesi",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _tabItem("Done", 0),
                      _tabItem("Cancelled", 1),
                    ],
                  ),
                ],
              ),
            ),

            /// ================= LIST =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  return _historyCard(currentList[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.purple : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _historyCard(Map<String, dynamic> data) {
    bool isDone = data["status"] == "Done";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(data["image"]),
          ),

          const SizedBox(width: 14),

          /// ================= INFO =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data["name"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),

                const SizedBox(height: 3),

                Text(data["role"],
                    style: TextStyle(color: Colors.grey[600])),

                const SizedBox(height: 4),

                Text(data["date"],
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data["status"],
                  style: TextStyle(
                    color: isDone ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              isDone
                  ? GestureDetector(
                      onTap: () => _showReviewSheet(data),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "See Review",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () {},
                      child: const Text("Reschedule"),
                    )
            ],
          )
        ],
      ),
    );
  }
}