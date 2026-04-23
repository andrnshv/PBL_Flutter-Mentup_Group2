import 'package:flutter/material.dart';

class MentorLandingPage extends StatefulWidget {
  const MentorLandingPage({super.key});

  @override
  State<MentorLandingPage> createState() => _MentorLandingPageState();
}

class _MentorLandingPageState extends State<MentorLandingPage> {
  int _selectedIndex = 0;

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

              // --- 3. UPCOMING SESSIONS ---
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
                      "Top 5",
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
                    _buildHorizontalSessionCard(
                      time: "08:00 - 12:00 WIB",
                      topic: "Coding",
                      clientName: "Chanyeol",
                      duration: "240 mins",
                      color: const Color(0xFFA7C7E7),
                    ),
                    _buildHorizontalSessionCard(
                      time: "15:00 - 18:00 WIB",
                      topic: "Statistics",
                      clientName: "Aiska",
                      duration: "180 mins",
                      color: const Color(0xFFF5B3CE),
                    ),
                    _buildHorizontalSessionCard(
                      time: "19:00 - 20:30 WIB",
                      topic: "English",
                      clientName: "Nabil",
                      duration: "90 mins",
                      color: const Color(0xFFCDB4DB),
                    ),
                    _buildHorizontalSessionCard(
                      time: "09:00 - 11:00 WIB",
                      topic: "Flutter",
                      clientName: "Andrian",
                      duration: "120 mins",
                      color: const Color(0xFFA7C7E7),
                    ),
                    _buildHorizontalSessionCard(
                      time: "13:00 - 14:30 WIB",
                      topic: "Database",
                      clientName: "Abi",
                      duration: "90 mins",
                      color: const Color(0xFFF5B3CE),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 4. RECENT REVIEWS ---
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
                  Text(
                    "See All",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5B62CC),
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
                      name: "Budi Santoso",
                      initial: "B",
                      rating: 5,
                      color: const Color(0xFFA7C7E7),
                      text:
                          "Kak Lovie penjelasannya mudah banget dipahami! Akhirnya aku ngerti konsep dasar UI/UX. Thank you kak!",
                    ),
                    _buildReviewCard(
                      name: "Aiska",
                      initial: "A",
                      rating: 5,
                      color: const Color(0xFFF5B3CE),
                      text:
                          "Sangat sabar ngajarin aku yang masih pemula di dunia programming. Recommended mentor deh!",
                    ),
                    _buildReviewCard(
                      name: "Chanyeol",
                      initial: "C",
                      rating: 4,
                      color: const Color(0xFFCDB4DB),
                      text:
                          "Materi terstruktur dengan baik. Mungkin next time bisa ditambahin lebih banyak contoh real-world case.",
                    ),
                    _buildReviewCard(
                      name: "Giselle",
                      initial: "G",
                      rating: 5,
                      color: const Color(0xFFA7C7E7),
                      text:
                          "Super detail dan cara komunikasinya asyik banget. Gak kerasa waktu belajarnya cepat berlalu!",
                    ),
                    _buildReviewCard(
                      name: "Andrian",
                      initial: "A",
                      rating: 5,
                      color: const Color(0xFFF5B3CE),
                      text:
                          "Sangat ngebantu buat persiapan ujianku. Mentor Lovie the best deh pokoknya, bakal order lagi!",
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
            const Text(
              "Mentor Lovie ✨",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(Icons.calendar_today_outlined),
            const SizedBox(width: 12),
            _buildIconButton(Icons.notifications_none_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
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
    );
  }

  Widget _buildQuickStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCDB4DB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            "168h",
            "Total Session",
            Icons.schedule,
            const Color(0xFFCDB4DB),
          ),
          Container(height: 40, width: 1, color: Colors.grey[200]),
          _buildStatItem(
            "Rp 1.5M",
            "Revenue",
            Icons.account_balance_wallet_outlined,
            const Color(0xFFA7C7E7),
          ),
          Container(height: 40, width: 1, color: Colors.grey[200]),
          _buildStatItem(
            "5.0",
            "Rating",
            Icons.star_border_rounded,
            const Color(0xFFF5B3CE),
          ),
        ],
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

  Widget _buildHorizontalSessionCard({
    required String time,
    required String topic,
    required String clientName,
    required String duration,
    required Color color,
  }) {
    return Container(
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
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
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
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String initial,
    required int rating,
    required Color color,
    required String text,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Border card opacity 50%
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                // Background avatar opacity 50%
                backgroundColor: color.withOpacity(0.5),
                radius: 20,
                // Inisial warna solid 100%
                child: Text(
                  initial,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: index < rating
                            ? Colors.amber
                            : Colors.grey.shade300,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\"$text\"",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: Colors.grey[800],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
            // LOGIKA NAVIGASI BARU DITAMBAHKAN DI SINI
            if (index == 1) {
              // Jika menu "Request" (index 1) diklik, pindah halaman
              Navigator.pushNamed(context, '/booking_request');
            } else {
              // Jika menu lain diklik, cukup ubah indikator warna saja
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
              label: "Request", // Ini adalah Index ke-1
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
