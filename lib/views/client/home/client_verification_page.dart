import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../data/dummy_data.dart';

class ClientVerificationPage extends StatefulWidget {
  const ClientVerificationPage({super.key});

  @override
  State<ClientVerificationPage> createState() => _ClientVerificationPageState();
}

class _ClientVerificationPageState extends State<ClientVerificationPage> {
  final Color primaryColor = const Color(0xFF5B62CC);

  bool isVerified = false;
  bool isRejected = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final String mentorName = args?['mentorName'] ?? "Unknown Mentor";
    final String category = args?['category'] ?? "Unknown";
    final String date = args?['date'] ?? "";
    final String time = args?['time'] ?? "";
    final String summary =
        args?['summary'] ??
        "Today we discussed the basics and completed the session successfully.";
    final String image = args?['image'] ?? "assets/profile.jpg";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          "Verify Session",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          mentorName[0],
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mentorName,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              category,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "$date • $time",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Session Proof",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ================= SUMMARY =================
                  const Text(
                    "Session Summary",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      summary,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (!isVerified && !isRejected)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                isRejected = true;
                              });

                              CherryToast.error(
                                title: const Text("Session Rejected"),
                                description: const Text(
                                  "Mentor will need to resubmit proof.",
                                ),
                                animationType: AnimationType.fromTop,
                                toastPosition: Position.top,
                              ).show(context);
                            },

                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Colors.redAccent),
                            ),

                            child: const Text(
                              "Reject",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// ================= VERIFY =================
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isVerified = true;
                              });

                              /// ================= MASUKKAN KE HISTORY =================
                              DummyData.historyMentors.add({
                                "name": mentorName,
                                "role": category,
                                "image": image,
                                "date": date,
                                "dateObject": DateTime.now(),
                                "status": "Done",

                                "rating": 0,
                                "review": null,
                                "isReviewed": false,
                              });

                              CherryToast.success(
                                title: const Text("Session Verified"),

                                description: const Text(
                                  "Thank you for confirming the session.",
                                ),

                                animationType: AnimationType.fromTop,

                                toastPosition: Position.top,
                              ).show(context);
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),

                            child: const Text(
                              "Verify",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  /// VERIFIED STATE
                  if (isVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.green),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "You have verified this mentoring session.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// REJECTED STATE
                  if (isRejected)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cancel_rounded, color: Colors.redAccent),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "You rejected this session proof.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
