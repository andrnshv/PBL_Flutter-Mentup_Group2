import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../controller/mentor/landing_controller.dart';
import '../../../models/mentor/landing_model.dart';

class MentorLandingPage extends StatefulWidget {
  const MentorLandingPage({super.key});

  @override
  State<MentorLandingPage> createState() => _MentorLandingPageState();
}

class _MentorLandingPageState extends State<MentorLandingPage> {
  final MentorLandingController _controller = MentorLandingController();
  int _selectedIndex = 0;

  static const Color _primary = Color(0xFF5B62CC);
  static const Color _bg = Color(0xFFF8F9FB);

  static const List<Color> _accentColors = [
    Color(0xFFF5B3CE),
    Color(0xFFA7C7E7),
    Color(0xFFCDB4DB),
    Color(0xFFB5EAD7),
    Color(0xFFFFDAC1),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchAll();
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(24.0),
            child: _controller.isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(
                        child: CircularProgressIndicator(color: _primary)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. HEADER ──────────────────
                      _buildHeader(),
                      const SizedBox(height: 30),

                      // ── 2. HERO BANNER ─────────────
                      _buildQuickStatsCard(),
                      const SizedBox(height: 35),

                      // ── 3. BOOKING REQUEST (paid) ──
                      _buildSectionHeader(
                        'New Booking Request',
                        badge: '${_controller.paidBookings.length} New',
                        onSeeAll: () =>
                            Navigator.pushNamed(context, '/booking_request'),
                      ),
                      const SizedBox(height: 15),
                      _controller.paidBookings.isEmpty
                          ? _buildEmptyState(
                              'Belum ada booking baru', Icons.inbox_outlined)
                          : Column(
                              children: _controller.paidBookings
                                  .asMap()
                                  .entries
                                  .map((e) =>
                                      _buildBookingRequestCard(e.value, e.key))
                                  .toList(),
                            ),
                      const SizedBox(height: 35),

                      // ── 4. UPCOMING SESSIONS (confirmed) ──
                      _buildSectionHeader(
                        'Upcoming Sessions',
                        badge: 'Top 3',
                        badgeColor: _primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 15),
                      _controller.confirmedSessions.isEmpty
                          ? _buildEmptyState('Belum ada sesi terjadwal',
                              Icons.event_busy_outlined)
                          : SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                clipBehavior: Clip.none,
                                itemCount: _controller.confirmedSessions.length,
                                itemBuilder: (_, i) =>
                                    _buildHorizontalSessionCard(
                                  _controller.confirmedSessions[i],
                                  i,
                                ),
                              ),
                            ),
                      const SizedBox(height: 35),

                      // ── 5. RECENT REVIEWS ──────────
                      _buildSectionHeader(
                        'Recent Reviews',
                        onSeeAll: () => Navigator.pushNamed(
                            context, AppRoutes.clientReviews),
                      ),
                      const SizedBox(height: 15),
                      _controller.reviews.isEmpty
                          ? _buildEmptyState(
                              'Belum ada ulasan', Icons.star_border_rounded)
                          : SizedBox(
                              height: 145,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                clipBehavior: Clip.none,
                                itemCount: _controller.reviews.length,
                                itemBuilder: (_, i) =>
                                    _buildReviewCard(_controller.reviews[i], i),
                              ),
                            ),
                      const SizedBox(height: 35),

                      // ── 6. TIPS BANNER ─────────────
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
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────
  // HEADER — foto profil + nama (tanpa welcome & emote)
  // ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    final profile = _controller.profile;
    final nama = profile?.nama ?? 'Mentor';
    final fotoUrl = profile?.fotoUrl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Foto profil + nama
        Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withOpacity(0.15),
                border:
                    Border.all(color: _primary.withOpacity(0.3), width: 1.5),
              ),
              child: fotoUrl != null && fotoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        fotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildAvatarFallback(nama),
                      ),
                    )
                  : _buildAvatarFallback(nama),
            ),
            const SizedBox(width: 12),
            // Nama
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Icon buttons
        Row(
          children: [
            _buildIconButton(
              Icons.calendar_today_outlined,
              onTap: () => Navigator.pushNamed(context, '/my_schedule'),
            ),
            const SizedBox(width: 12),
            _buildIconButton(
              Icons.star_rate_outlined,
              onTap: () => Navigator.pushNamed(context, '/client_reviews'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarFallback(String nama) {
    return Center(
      child: Text(
        nama.isNotEmpty ? nama[0].toUpperCase() : 'M',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _primary,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: _primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: _primary, size: 20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // HERO BANNER
  // ─────────────────────────────────────────────────────
  Widget _buildQuickStatsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCDB4DB), Color(0xFFA7C7E7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCDB4DB).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
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
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
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
                      "Ready to hit the ground running today? MentUp is here to keep track of your schedule!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
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

  // ─────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title, {
    String? badge,
    Color? badgeColor,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFF5B3CE).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // BOOKING REQUEST CARD (paid)
  // ─────────────────────────────────────────────────────
  Widget _buildBookingRequestCard(MentorBookingRequestItem item, int index) {
    final color = _accentColors[index % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/booking_request',
      ),
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
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: item.clientFotoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child:
                          Image.network(item.clientFotoUrl!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        item.clientName.isNotEmpty
                            ? item.clientName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.clientName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        item.dateLabel,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        item.timeLabel,
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
            // Badge kategori
            if (item.categoryName != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.categoryName!,
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

  // ─────────────────────────────────────────────────────
  // UPCOMING SESSION CARD (confirmed)
  // ─────────────────────────────────────────────────────
  Widget _buildHorizontalSessionCard(MentorUpcomingSession item, int index) {
    final color = _accentColors[index % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/booking_detail',
        arguments: {
          'bookingId': item.bookingId,
          'color': color,
        },
      ),
      child: Container(
        width: 270,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, color: color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Confirmed',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.clientName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (item.categoryName != null)
                    Text(
                      item.categoryName!,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.timeLabel,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
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

  // ─────────────────────────────────────────────────────
  // REVIEW CARD
  // ─────────────────────────────────────────────────────
  Widget _buildReviewCard(MentorReviewItem item, int index) {
    final color = _accentColors[index % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.clientReviews,
        arguments: {'studentName': item.clientName},
      ),
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
                // Avatar client
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: item.clientFotoUrl != null
                      ? ClipOval(
                          child: Image.network(item.clientFotoUrl!,
                              fit: BoxFit.cover),
                        )
                      : Center(
                          child: Text(
                            item.initial,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.clientName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Bintang rating
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: i < item.rating ? Colors.amber : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.reviewText != null && item.reviewText!.isNotEmpty
                  ? '"${item.reviewText!}"'
                  : '-',
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

  // ─────────────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────────────
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.grey[400],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // TIPS BANNER
  // ─────────────────────────────────────────────────────
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
            onPressed: () => Navigator.pushNamed(context, '/mentor_tips'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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

  // ─────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────
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
          selectedItemColor: _primary,
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
                icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined), label: "Request"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
