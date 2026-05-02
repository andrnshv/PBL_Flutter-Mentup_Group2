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
      "days": ["Mon", "Wed"],
      "hours": 2,
      "months": 1,
      "note": "Belajar integral",

      "status": "Done",
      "rating": 4,
      "review": "Mentor sangat membantu",
    },
    {
      "name": "Belva",
      "role": "UX Designer",
      "image": "assets/mentor2.jpg",
      "date": "10 April 2026",

      "dateObject": DateTime(2026, 4, 10),
      "days": ["Tue"],
      "hours": 1,
      "months": 1,
      "note": "",

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
      "days": ["Fri"],
      "hours": 1,
      "months": 1,
      "note": "",

      "status": "Cancelled",
      "rating": 0,
      "review": null,
    },
  ];

  /// ================= STAR =================
  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  /// ================= OPEN PROFILE =================
  void _openProfile(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MentorProfilePage(
          mentor: MentorModel(
            name: data["name"],
            category: data["role"],
            image: data["image"],
            rating: (data["rating"] ?? 0).toDouble(),
            price: 0,
            distance: 0,
            phone: null,
          ),
        ),
      ),
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    List done =
        historyMentors.where((e) => e["status"] == "Done").toList();

    // 🔥 FIX: Rescheduled tetap muncul di tab ini
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
            /// HEADER
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

            /// LIST
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

  /// ================= TAB =================
  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: AssetImage(data["image"]),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data["name"],
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(data["role"],
                    style: const TextStyle(color: Colors.grey)),
                Text(data["date"],
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),

          Column(
            children: [
              Text(
                data["status"],
                style: TextStyle(
                  color: isDone ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              isDone
                  ? TextButton(
                      onPressed: () {},
                      child: const Text("See Reviews"),
                    )
                  : OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(
                              mentor: MentorModel(
                                name: data["name"],
                                category: data["role"],
                                image: data["image"],
                                rating: (data["rating"] ?? 0)
                                    .toDouble(),
                                price: 0,
                                distance: 0,
                                phone: null,
                              ),
                              isReschedule: true,
                              oldData: data,
                            ),
                          ),
                        );

                        if (result != null &&
                            result["updated"] == true) {
                          setState(() {
                            data["status"] = "Rescheduled";

                            data["dateObject"] = result["newDate"];
                            data["days"] = result["newDays"];

                            data["date"] =
                                "${result["newDate"].day}/${result["newDate"].month}/${result["newDate"].year}";
                          });
                        }
                      },
                      child: const Text("Reschedule"),
                    )
            ],
          )
        ],
      ),
    );
  }
}