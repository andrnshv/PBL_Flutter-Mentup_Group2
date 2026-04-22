import 'package:flutter/material.dart';
import '../profile/mentor_profile_page.dart';
import '../../../models/mentor_model.dart';

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
      "status": "Done",
      "rating": 4,
      "review": "Mentor sangat membantu dan penjelasannya mudah dipahami",
    },
    {
      "name": "Belva",
      "role": "UX Designer",
      "image": "assets/mentor2.jpg",
      "date": "10 April 2026",
      "status": "Done",
      "rating": 0,
      "review": null,
    },
    {
      "name": "Loey",
      "role": "Music",
      "image": "assets/profile.jpg",
      "date": "5 April 2026",
      "status": "Cancelled",
      "rating": 0,
      "review": null,
    },
  ];

  /// STAR
  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          ),
        );
      }),
    );
  }

  /// OPEN PROFILE
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

  /// REVIEW MODAL
  void _openReview(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Review Mentor",
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(data["image"]),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    data["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (data["review"] != null) ...[
                _buildStars(data["rating"]),
                const SizedBox(height: 10),
                Text(data["review"]),
              ] else ...[
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.rate_review,
                          size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No reviews yet"),
                    ],
                  ),
                )
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List done =
        historyMentors.where((e) => e["status"] == "Done").toList();
    List cancelled =
        historyMentors.where((e) => e["status"] == "Cancelled").toList();

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
                  const SizedBox(height: 5),
                  const Text(
                    "Pantau aktivitas mentoring kamu",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  /// TAB
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _tabItem("Done", 0),
                        _tabItem("Cancelled", 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: currentList.isEmpty
                    ? const Center(child: Text("No history yet"))
                    : ListView.builder(
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          return _historyCard(currentList[index]);
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// TAB
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

  /// CARD 
  Widget _historyCard(Map<String, dynamic> data) {
    bool isDone = data["status"] == "Done";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openProfile(data),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(data["role"],
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(data["date"],
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),

                    if (data["rating"] > 0) ...[
                      const SizedBox(height: 6),
                      _buildStars(data["rating"]),
                    ]
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  isDone
                      ? TextButton(
                          onPressed: () => _openReview(data),
                          child: const Text("See Reviews"),
                        )
                      : OutlinedButton(
                          onPressed: () {},
                          child: const Text("Reschedule"),
                        )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}