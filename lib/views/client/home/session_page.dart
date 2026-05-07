import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../../../models/mentor_model.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final Color primary = const Color(0xFF6C63FF);

  final List<MentorModel> mentors = DummyData.mentors;

  final List<bool> completedStatus = [];
  final List<int> ratings = [];
  final List<TextEditingController> reviewControllers = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < mentors.length; i++) {
      completedStatus.add(false);
      ratings.add(0);
      reviewControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in reviewControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// ================= STAR WIDGET =================
  Widget buildStars(
    int mentorIndex,
    void Function(void Function()) modalSetState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            modalSetState(() {
              ratings[mentorIndex] = index + 1;
            });
          },
          icon: Icon(
            index < ratings[mentorIndex]
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
  }

  /// ================= RATING MODAL =================
  void openRating(int mentorIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Session Verification",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Give feedback for ${mentors[mentorIndex].name}",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  buildStars(mentorIndex, modalSetState),

                  const SizedBox(height: 10),

                  TextField(
                    controller: reviewControllers[mentorIndex],
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {

                      setState(() {
                        completedStatus[mentorIndex] = true;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${mentors[mentorIndex].name} session completed",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Submit Verification",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ================= SESSION CARD =================
  Widget buildSessionCard(int index) {

    final mentor = mentors[index];
    final isCompleted = completedStatus[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),

      child: Column(
        children: [

          /// TOP SECTION
          Row(
            children: [

              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(mentor.image),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      mentor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      mentor.category,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Today • 13:00 - 15:00",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? "Completed" : "Ongoing",
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// BUTTON / COMPLETED VIEW
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => openRating(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Complete Session",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (isCompleted) ...[

            const Divider(),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ratings[index],
                (i) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              reviewControllers[index].text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Today's Sessions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Active Mentoring Sessions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Verify completed learning sessions with your mentors.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          ...List.generate(
            mentors.length,
            (index) => buildSessionCard(index),
          ),
        ],
      ),
    );
  }
}