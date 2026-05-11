import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class MyMentorsPage extends StatelessWidget {
  const MyMentorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final activeMentors = DummyData.mentors;
    final history = DummyData.historyMentors;

    return Scaffold(
      appBar: AppBar(title: const Text("My Mentors")),
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Active Mentors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ...activeMentors.map((mentor) {
              return _mentorCard(
                name: mentor.name,
                role: mentor.category,
                image: mentor.image,
                status: "Active",
                color: Colors.green,
              );
            }),

            const SizedBox(height: 20),

            /// PAST MENTORS
            const Text(
              "Past Mentors",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            ...history.map((m) {
              return _mentorCard(
                name: m["name"],
                role: m["role"],
                image: m["image"],
                status: m["status"],
                color: m["status"] == "Done"
                    ? Colors.blue
                    : Colors.grey,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _mentorCard({
    required String name,
    required String role,
    required String image,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(role),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}