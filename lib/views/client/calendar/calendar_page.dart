import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'add_session_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  final Color primary = const Color(0xFF6C63FF);
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ================= BACK + TITLE =================
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Calender",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// ================= ADD BUTTON =================
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSessionPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.pink),
                      SizedBox(width: 8),
                      Text(
                        "Add to your calender",
                        style: TextStyle(color: Colors.pink),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= CALENDAR =================
              TableCalendar(
                focusedDay: today,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                selectedDayPredicate: (day) => isSameDay(day, today),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    today = selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ================= SESSION TITLE =================
              Container(
                height: 3,
                color: primary,
              ),
              const SizedBox(height: 10),

              const Text(
                "Sesion for today",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),

              const SizedBox(height: 10),

              /// ================= SESSION LIST =================
              Expanded(
                child: ListView(
                  children: const [

                    _SessionItem(
                      name: "Albert",
                      date: "12 May 2026",
                      time: "11:00 - 10:30 am",
                    ),

                    _SessionItem(
                      name: "Mirnaty",
                      date: "12 May 2026",
                      time: "13:00 - 13:40 am",
                    ),

                    _SessionItem(
                      name: "Helda",
                      date: "12 May 2026",
                      time: "15:00 - 16:00 am",
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= COMPONENT SESSION ITEM =================
class _SessionItem extends StatelessWidget {
  final String name;
  final String date;
  final String time;

  const _SessionItem({
    required this.name,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Sesion with $name",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
        ],
      ),
    );
  }
}