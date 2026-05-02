import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSessionPage extends StatefulWidget {
  const AddSessionPage({super.key});

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final Color primary = const Color(0xFF6C63FF);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add Session",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= HEADER =================
            Text(
              "Create New Session",
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              "Fill in the details below",
              style: GoogleFonts.nunito(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// ================= CARD FORM =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [

                  /// ================= NAME =================
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.nunito(),
                    decoration: InputDecoration(
                      labelText: "Mentor Name",
                      labelStyle: GoogleFonts.nunito(),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ================= DATE =================
                  TextField(
                    controller: dateController,
                    style: GoogleFonts.nunito(),
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText: "12 May 2026",
                      labelStyle: GoogleFonts.nunito(),
                      hintStyle: GoogleFonts.nunito(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ================= TIME =================
                  TextField(
                    controller: timeController,
                    style: GoogleFonts.nunito(),
                    decoration: InputDecoration(
                      labelText: "Time",
                      hintText: "10:00 - 11:00",
                      labelStyle: GoogleFonts.nunito(),
                      hintStyle: GoogleFonts.nunito(),
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= SAVE BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B45D6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Save Session",
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}