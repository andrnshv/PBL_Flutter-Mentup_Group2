import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MentorLandingPage extends StatefulWidget {
  const MentorLandingPage({super.key});

  @override
  State<MentorLandingPage> createState() => _MentorLandingPageState();
}

class _MentorLandingPageState extends State<MentorLandingPage> {
  int _selectedIndex = 0;

//memanggil nama user dari metadata Supabase
   String getUserName() {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return 'User';
    }

    final nama =
        user.userMetadata?['nama_lengkap'];

    return nama ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),

              // --- 1. OVERVIEW STATISTIK ---
              const Text(
                "Overview",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildQuickStatsCard(),

              const SizedBox(height: 35),

              // --- 2. NEW BOOKING REQUEST ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Booking Request",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/booking_request'),
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            color: Color(0xFF5B62CC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5B3CE).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "3 New",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Memanggil data dan menampilkannya satu per satu
              ...([
                {
                  "name": "Aiska",
                  "cat": "Statistics",
                  "date": "21 Apr",
                  "time": "09:00",
                  "color": const Color(0xFFF5B3CE),
                },
                {
                  "name": "Bima",
                  "cat": "Web Dev",
                  "date": "22 Apr",
                  "time": "13:00",
                  "color": const Color(0xFFA7C7E7),
                },
                {
                  "name": "Citra",
                  "cat": "UI/UX Design",
                  "date": "23 Apr",
                  "time": "15:00",
                  "color": const Color(0xFFCDB4DB),
                },
              ].map((item) {
                return _buildBookingRequestCard(
                  clientName: item['name'] as String,
                  category: item['cat'] as String,
                  date: item['date'] as String,
                  time: item['time'] as String,
                  color: item['color'] as Color,
                );
              }).toList()),

              const SizedBox(height: 35),

              // --- 3. UPCOMING SESSIONS (Dimodifikasi Sesuai MySchedulePage) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upcoming Sessions",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF5B62CC,
                      ).withOpacity(0.5), // Ungu 50%
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Top 3",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B62CC),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  children: [
                    // Urutan 1: Pagi (09:00)
                    _buildHorizontalSessionCard(
                      time: "09:00 - 11:00 WIB",
                      topic: "Statistics",
                      clientName: "Aiska Rahma",
                      duration: "120 mins",
                      color: const Color(0xFFF5B3CE),
                      location: "https://zoom.us/j/123456789",
                    ),
                    // Urutan 2: Siang (13:00)
                    _buildHorizontalSessionCard(
                      time: "13:00 - 15:00 WIB",
                      topic: "Web Dev",
                      clientName: "Budi Santoso",
                      duration: "120 mins",
                      color: const Color(0xFFA7C7E7),
                      location: "Library Central Park",
                    ),
                    // Urutan 3: Sore (15:30)
                    _buildHorizontalSessionCard(
                      time: "15:30 - 17:00 WIB",
                      topic: "UI/UX Design",
                      clientName: "Citra Kirana",
                      duration: "90 mins",
                      color: const Color(0xFFCDB4DB),
                      location: "https://meet.google.com/abc",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 4. RECENT REVIEWS ---
              // --- HEADER RECENT REVIEWS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Reviews",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman review (Menampilkan SEMUA)
                      Navigator.pushNamed(context, AppRoutes.clientReviews);
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Color(0xFF5B62CC),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 145,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  children: [
                    _buildReviewCard(
                      name: "Aiska Rahma",
                      initial: "A",
                      rating: 5,
                      color: const Color(0xFFF5B3CE),
                      text:
                          "Penjelasannya sangat mudah dimengerti! Kak Lovie sabar banget ngajarin konsep hipotesis.",
                      context: context,
                    ),
                    _buildReviewCard(
                      name: "Bima Santoso",
                      initial: "B",
                      rating: 4,
                      color: const Color(0xFFA7C7E7),
                      text:
                          "Keren banget materinya, langsung praktek bikin Flexbox. Cuman internetku agak lemot tadi.",
                      context: context,
                    ),
                    _buildReviewCard(
                      name: "Citra Kirana",
                      initial: "C",
                      rating: 5,
                      color: const Color(0xFFCDB4DB),
                      text:
                          "Design system yang diajarin kak Lovie rapi banget. Puas bgt!",
                      context: context,
                    ),
                    _buildReviewCard(
                      name: "Chanyeol",
                      initial: "C",
                      rating: 4,
                      color: const Color(0xFFCDB4DB),
                      text:
                          "Materi terstruktur dengan baik. Mungkin next time bisa ditambahin lebih banyak contoh.",
                      context: context,
                    ),
                    _buildReviewCard(
                      name: "Giselle",
                      initial: "G",
                      rating: 5,
                      color: const Color(0xFFA7C7E7),
                      text:
                          "Super detail dan cara komunikasinya asyik banget. Gak kerasa waktu belajarnya cepat berlalu!",
                      context: context,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 5. MENTUP TIPS BANNER ---
              const Text(
                "MentUp Tips",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildTipsBanner(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==================== WIDGET HELPERS ====================

    Widget _buildHeader() {
  final userName = getUserName();

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello,",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            Text(
              "Welcome $userName ✨",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(width: 10),

      Row(
        children: [
          _buildIconButton(
            Icons.calendar_today_outlined,
            onTap: () => Navigator.pushNamed(
              context,
              '/my_schedule',
            ),
          ),

          const SizedBox(width: 12),

          _buildIconButton(
            Icons.star_rate_outlined,
            onTap: () => Navigator.pushNamed(
              context,
              '/client_reviews',
            ),
          ),
        ],
      ),
    ],
  );
}

  // Perubahan: Menambahkan parameter onTap pada _buildIconButton
  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          // Border opacity 50%
          border: Border.all(
            color: const Color(0xFF5B62CC).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: const Color(0xFF5B62CC), size: 20),
      ),
    );
  }

  // --- REVISI FINAL: THE REAL MODERN HERO BANNER (CLEAN & FLOATING LOGO) ---
  Widget _buildQuickStatsCard() {
    return Container(
      width: double.infinity,
      // Tetap tanpa 'height' kaku agar anti-overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCDB4DB), // Lavender
            Color(0xFFA7C7E7), // Pastel Blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCDB4DB).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // ClipRRect agar elemen yang melayang di pojok tidak keluar dari lengkungan radius
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // --- 1. MOTIF BUBBLE AESTHETIC ---
            Positioned(
              top: -20,
              left: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.12),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
            ),
            Positioned(
              top: 20,
              right: 80,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white.withOpacity(0.15),
              ),
            ),

            // --- 2. LOGO MENTUP MELAYANG (Tanpa Bingkai Kaku!) ---
            Positioned(
              right:
                  -10, // Sengaja digeser dikit ke kanan biar ada efek "bleed" estetik
              top: 0,
              bottom:
                  0, // Kombinasi top & bottom 0 akan membuat image otomatis rata tengah vertikal
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width:
                      140, // Ukuran raksasa tapi natural karena tidak ada bingkai
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),

            // --- 3. KONTEN TEKS & SAPAAN ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Hello, Mentor 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ready to hit the ground running today? MentUp is here to keep track of your schedule, so you can focus on delivering your best without any worries!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Glassmorphism Badge Modern
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        "Mentor Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          // Background icon opacity 50%
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          // Icon warna solid 100% (tone-on-tone)
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingRequestCard({
    required String clientName,
    required String category,
    required String date,
    required String time,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke detail dengan data lengkap
        Navigator.pushNamed(
          context,
          '/booking_detail',
          arguments: {
            'name': clientName,
            'cat': category,
            'date': date,
            'time': time,
            'color': color,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar dengan Initial
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                clientName[0],
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Baris Tanggal & Jam
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chip Kategori di pojok kanan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Perubahan: Menambahkan logika onTap yang diarahkan ke Accepted page
  Widget _buildHorizontalSessionCard({
    required String time,
    required String topic,
    required String clientName,
    required String duration,
    required Color color,
    required String location,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/booking_detail',
          arguments: {
            'name': clientName,
            'cat': topic,
            'time': time,
            'date': "Today", // Bisa disesuaikan jadi dinamis nanti
            'color': color,
            'location': location,
            'status': 'Accepted', // CRITICAL: agar masuk UI Accepted
            'totalPrice': 'Paid',
            'note': "This session is already accepted and scheduled.",
          },
        );
      },
      child: Container(
        width: 270,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Border card opacity 50%
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                // Background icon opacity 50%
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    color: color,
                    size: 24,
                  ), // Ikon solid 100%
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String initial,
    required int rating,
    required Color color,
    required String text,
    required BuildContext context, // Tambahkan parameter context
  }) {
    return GestureDetector(
      onTap: () {
        // NAVIGASI DENGAN FILTER NAMA
        Navigator.pushNamed(
          context,
          AppRoutes.clientReviews,
          arguments: {'studentName': name},
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
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
                  backgroundColor: color.withOpacity(0.2),
                  radius: 18,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: index < rating ? Colors.amber : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "\"$text\"",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFCDB4DB), Color(0xFFA7C7E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "PRO TIP",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "How to engage your\nstudents better?",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/mentor_tips');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5B62CC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Read Article",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              setState(() => _selectedIndex = index);
            } else if (index == 1) {
              Navigator.pushNamed(context, '/booking_request');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/transactions');
            } else if (index == 3) {
              Navigator.pushNamed(context, '/mentor_profile');
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5B62CC),
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: "Request",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
