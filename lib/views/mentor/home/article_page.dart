import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FB,
      ), // Latar belakang abu-abu sangat muda
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            // --- 1. BACKGROUND HEADER GRADIENT ---
            Container(
              height: 360,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFCDB4DB),
                    Color(0xFFA7C7E7),
                  ], // Lavender ke Biru
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Pola air/lingkaran dekoratif (Opsional biar ga kosong)
                  Positioned(
                    right: -50,
                    top: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    top: 150,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Ikon Utama Header
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(
                        Icons.tips_and_updates_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. TOMBOL BACK & BOOKMARK (DI ATAS HEADER) ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopIconButton(
                      context,
                      Icons.arrow_back_rounded,
                      () => Navigator.pop(context),
                    ),
                    _buildTopIconButton(
                      context,
                      Icons.bookmark_border_rounded,
                      () {},
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. KONTEN ARTIKEL (OVERLAP KE ATAS) ---
            Container(
              margin: const EdgeInsets.only(
                top: 280,
              ), // Menimpa header gradient
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF5B3CE,
                        ).withOpacity(0.2), // Pink transparan
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF5B3CE),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        "MENTUP PRO TIPS",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE91E63),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul Artikel
                  const Text(
                    "How to engage your students better during a session?",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Author Profile Card
                  _buildAuthorCard(),

                  const SizedBox(height: 30),

                  // Paragraf Pembuka
                  _buildParagraph(
                    "Teaching a technical skill like programming or UI/UX design can sometimes feel one-sided. As a mentor, your goal isn't just to transfer knowledge, but to ensure your students are actively engaged and actually enjoying the learning process.",
                  ),
                  const SizedBox(height: 30),

                  // --- KARTU TIPS 1 (LAVENDER) ---
                  _buildTipCard(
                    number: "01",
                    title: "Start with a Quick Check-in",
                    content:
                        "Don't jump straight into the code. Spend the first 5 minutes asking about their day or any difficulties they faced in the previous assignment. Building a connection makes students more comfortable asking questions later.",
                    color: const Color(0xFFCDB4DB), // Lavender
                  ),
                  const SizedBox(height: 20),

                  // --- KARTU TIPS 2 (PINK) ---
                  _buildTipCard(
                    number: "02",
                    title: "Apply the 80/20 Rule",
                    content:
                        "Avoid lecturing for the entire session. Keep your theory explanation to 20% of the time, and let the student do hands-on practice (like live coding or collaborating on Figma) for the remaining 80%.",
                    color: const Color(0xFFF5B3CE), // Pink
                  ),
                  const SizedBox(height: 20),

                  // --- KARTU TIPS 3 (BIRU) ---
                  _buildTipCard(
                    number: "03",
                    title: "Set Mini Milestones",
                    content:
                        "Break down the material into small, achievable tasks. Every time a student completes a mini-task, celebrate it! This boosts their confidence and keeps their energy high throughout the session.",
                    color: const Color(0xFFA7C7E7), // Biru Muda
                  ),

                  const SizedBox(height: 35),

                  // Kotak Kesimpulan (Key Takeaway)
                  _buildKeyTakeaway(),

                  const SizedBox(height: 40),

                  // Feedback Section
                  const Center(
                    child: Text(
                      "Was this article helpful?",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeedbackButton(
                        Icons.thumb_up_alt_rounded,
                        "Yes, absolutely!",
                        const Color(0xFF5B62CC),
                        true,
                      ),
                      const SizedBox(width: 15),
                      _buildFeedbackButton(
                        Icons.thumb_down_alt_rounded,
                        "Not really",
                        Colors.grey.shade400,
                        false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50), // Ruang lega di paling bawah
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button untuk Share
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // INI LOGIKA ASLINYA (Sangat simpel kan?)
          Share.share(
            'Check out this great tip for mentors on MentUp: "How to engage your students better during a session?" Download the app now!',
            subject: 'MentUp Pro Tips',
          );
        },
        backgroundColor: const Color(0xFF5B62CC),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.share_rounded, color: Colors.white),
      ),
    );
  }

  // ==================== WIDGET HELPERS ====================

  Widget _buildTopIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3), // Efek Glassmorphism transparan
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildAuthorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFCDB4DB), Color(0xFFA7C7E7)],
              ),
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.support_agent_rounded,
                size: 26,
                color: Color(0xFF5B62CC),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MentUp Team",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Content & Mentor Success",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(height: 4),
                Text(
                  "3 min",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        color: Colors.grey[800],
        height: 1.7, // Jarak antar baris diperlebar biar nyaman dibaca
      ),
    );
  }

  // --- WIDGET KARTU TIPS YANG MODERN ---
  Widget _buildTipCard({
    required String number,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Background tipis
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis aksen solid di sebelah kiri
          Container(
            width: 8,
            height: 140, // Bisa disesuaikan
            decoration: BoxDecoration(
              color: color, // Warna solid
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        number,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTakeaway() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B62CC), // Ungu gelap solid
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B62CC).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.stars_rounded, color: Colors.amber, size: 30),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Key Takeaway",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "A great mentor makes the learning process feel like a collaboration, not a lecture. Keep it interactive!",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(
    IconData icon,
    String label,
    Color color,
    bool isSolid,
  ) {
    return isSolid
        ? ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(icon, color: Colors.white, size: 20),
            label: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(icon, color: color, size: 20),
            label: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
  }
}
