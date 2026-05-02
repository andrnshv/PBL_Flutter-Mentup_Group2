import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  // MentUp Color Palette
  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color primaryBlue = const Color(0xFF6D92CB);
  final Color bgGray = const Color(0xFFF8F9FB);
  final Color textDark = const Color(0xFF2D3436);

  // Daftar FAQ Lengkap
  final List<Map<String, String>> faqs = [
    {
      "q": "How does the platform fee work?",

      "a":
          "MentUp applies a 10% service fee on every booking to maintain platform operations.",
    },

    {
      "q": "When do I get my payment?",

      "a":
          "Earnings are processed by admin first, then transferred to your registered account.",
    },

    {
      "q": "Can I cancel a booking?",

      "a": "No, you cannot cancel the session if you already accept it.",
    },

    {
      "q": "How do I change my hourly rate?",

      "a":
          "You can update your teaching fee anytime from the 'Service Rates' menu. Please note that rate changes will only apply to new incoming bookings.",
    },

    {
      "q": "What if a client is late or doesn't show up?",

      "a":
          "If a client is late, you are only required to teach for the remaining scheduled time. If they don't show up, you can fill the teaching form to complaint and still receive full payment.",
    },

    {
      "q": "How does the rating system work?",

      "a":
          "After each completed session, client can leave a rating (1-5 stars) and a review. Maintaining a rating above 4.5 will boost your visibility on the search page!",
    },

    {
      "q": "What should I do if we experience technical issues?",

      "a": "We provide help center so you can contact us anytime!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: Stack(
        children: [
          // --- LAYER 1: BACKGROUND GRADASI & GLOW KUNING ---
          _buildBackground(),

          // --- LAYER 2: KONTEN UTAMA ---
          Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 10),

              // --- FLOATING FAQ CARD ---
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline_rounded,
                                    color: primaryPurple,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Top Questions",
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // --- YELLOW HINT BOX ---
                              _buildYellowHint(),

                              // --- LIST FAQ ---
                              ...faqs
                                  .map((f) => _buildFaqItem(f['q']!, f['a']!))
                                  .toList(),
                            ],
                          ),
                        ),

                        // --- COMPLAINT SECTION (Bawah) ---
                        _buildComplaintSection(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Efek Glow Kuning
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF39C12).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Motif Garis
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: LinePatternPainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "FAQ & Support",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 48), // Spacer biar title tetap di tengah
          ],
        ),
      ),
    );
  }

  Widget _buildYellowHint() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Kuning super pastel
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD166),
          width: 1.5,
        ), // Border kuning tegas
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFF39C12),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Hint",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD68910),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Can't find the answer you're looking for? Scroll to the bottom to submit a direct form to our admin team!",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryPurple,
          collapsedIconColor: Colors.grey[400],
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          title: Text(
            q,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: textDark,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.grey.withOpacity(0.1), height: 1),
            const SizedBox(height: 15),
            Text(
              a,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgGray,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          const Text(
            "Still need help?",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Our support team is ready to assist you.",
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () => _showComplaintPopOut(context),
              child: const Text(
                "Submit a form",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComplaintPopOut(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Submit Form",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 25),
              _buildField("Subject (e.g., Payment Issue)"),
              const SizedBox(height: 15),
              _buildField("Describe your problem in detail...", maxLines: 4),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Form submitted successfully!",
                          style: TextStyle(fontFamily: 'Nunito'),
                        ),
                        backgroundColor: primaryPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Send Form",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: bgGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class LinePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
