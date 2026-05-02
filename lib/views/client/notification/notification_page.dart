import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// ================= NOTIFICATION ITEM =================
          _notifItem(
            icon: Icons.calendar_today,
            title: "Upcoming Session",
            subtitle: "You have a session with Albert at 11:00 AM",
            time: "10 min ago",
          ),

          _notifItem(
            icon: Icons.star,
            title: "New Mentor Available",
            subtitle: "Check out new mentors in Technology",
            time: "1 hour ago",
          ),

          _notifItem(
            icon: Icons.check_circle,
            title: "Booking Confirmed",
            subtitle: "Your booking has been confirmed",
            time: "Yesterday",
          ),
        ],
      ),
    );
  }

  Widget _notifItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          )
        ],
      ),
    );
  }
}