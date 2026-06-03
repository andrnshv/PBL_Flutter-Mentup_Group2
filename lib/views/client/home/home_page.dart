import 'package:flutter/material.dart';
import 'package:flutter_mentup/models/mentor_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../controller/client/verify_session_controller.dart';
import 'client_verification_page.dart';
import '../../../controller/client/profile_controller.dart';
import '../../../models/client/profile_model.dart';
import '../../../controller/client/calendar_controller.dart';
import '../../../controller/client/nearby_mentors_controller.dart';
import '../profile/mentor_profile_page.dart';
import '../../../controller/client/top_mentors_controller.dart';
import '../../../controller/client/comment_controller.dart';

import '../calendar/calendar_page.dart';
import '../search/search_page.dart';
import '../History/History_page.dart';
import '../profile/profile_page.dart';
import '../notification/notification_page.dart';
import '../data/dummy_data.dart';
import '../../../routes/app_routes.dart';
import '../../../services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _LandingPageState();
}

class _LandingPageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _namaUser = '';
  String? _fotoUrl; // ← foto profil dari bio_profil
  bool _loadingUser = true;
  final ProfileController _profileController = ProfileController();

  final _verifyCtrl = VerifySessionController(); // ← TAMBAH INI
  bool _loadingVerify = true;

  final _calendarCtrl = CalendarController();
  SessionItemModel? _nextSession; // sesi terdekat
  bool _loadingSession = true;

  final _nearbyCtrl = NearbyMentorsController();
  bool _loadingNearby = true;

  final _topMentorsCtrl = TopMentorsController();
  bool _loadingTop = true;

  final _testimonialCtrl = WhatTheySayController();
  bool _loadingTestimonial = true;

  static const LatLng _center = LatLng(-7.9425, 112.6131);
  final Color primary = const Color(0xFF6C63FF);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVerifications();
    _loadNextSession();
    _loadNearbyMentors();
    _loadTopMentors();
    _loadTestimonials();
    _pages = [
      _homeContent(),
      const SearchPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
  }

  Future<void> _loadTestimonials() async {
    await _testimonialCtrl.fetchTestimonials();
    if (mounted) {
      setState(() {
        _loadingTestimonial = false;
        _pages[0] = _homeContent();
      });
    }
  }

  Future<void> _loadTopMentors() async {
    await _topMentorsCtrl.fetchTopMentors();
    if (mounted) {
      setState(() {
        _loadingTop = false;
        _pages[0] = _homeContent();
      });
    }
  }

  void _focusToMentor(GoogleMapController controller) {
    final mentors = _nearbyCtrl.nearbyMentors;

    if (mentors.isEmpty) {
      // Tidak ada mentor → fokus ke lokasi client
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_nearbyCtrl.cameraCenter, 13),
      );
      return;
    }

    if (mentors.length == 1) {
      // 1 mentor → langsung fokus ke markernya
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(mentors.first.latitude, mentors.first.longitude),
          14,
        ),
      );
      return;
    }

    // Banyak mentor → atur kamera agar semua marker terlihat
    double minLat = mentors.first.latitude;
    double maxLat = mentors.first.latitude;
    double minLng = mentors.first.longitude;
    double maxLng = mentors.first.longitude;

    for (final m in mentors) {
      if (m.latitude < minLat) minLat = m.latitude;
      if (m.latitude > maxLat) maxLat = m.latitude;
      if (m.longitude < minLng) minLng = m.longitude;
      if (m.longitude > maxLng) maxLng = m.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60, // padding (px)
      ),
    );
  }

  Future<void> _loadNearbyMentors() async {
    debugPrint('[NEARBY] _loadNearbyMentors dipanggil!');
    await _nearbyCtrl.fetchNearbyMentors(
      onMarkerTap: (mentorId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MentorProfilePage(mentorId: mentorId),
          ),
        );
      },
    );
    if (mounted) {
      setState(() {
        _loadingNearby = false;
        _pages[0] = _homeContent();
      });
    }
  }

  Future<void> _loadNextSession() async {
    await _calendarCtrl.fetchSessions();

    // Cari sesi terdekat: tanggal >= hari ini, diurutkan paling awal
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    final upcoming = _calendarCtrl.allSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return !d.isBefore(todayMidnight); // hari ini atau ke depan
    }).toList()
      ..sort((a, b) {
        // urutkan berdasarkan tanggal, lalu jam mulai
        final dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.timeLabel.compareTo(b.timeLabel);
      });

    if (mounted) {
      setState(() {
        _nextSession = upcoming.isNotEmpty ? upcoming.first : null;
        _loadingSession = false;
        _pages[0] = _homeContent(); // refresh home
      });
    }
  }

  Future<void> _loadVerifications() async {
    await _verifyCtrl.fetchPendingVerifications();
    if (mounted) {
      setState(() {
        _loadingVerify = false;
        _pages[0] = _homeContent(); // refresh tampilan home
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final ProfileModel? profile = await _profileController.getProfile();

      if (mounted) {
        setState(() {
          _namaUser = profile?.namaLengkap ?? '';
          _fotoUrl = profile?.fotoUrl;
          _loadingUser = false;
          _pages[0] = _homeContent(); // refresh home
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.search, "Search", 1),
            _navItem(Icons.people, "History", 2),
            _navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  // Kartu loading (saat data sedang diambil)
  Widget _loadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  // Kartu "belum ada sesi untuk diverifikasi"
  Widget _emptyVerifyCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.verified_outlined, color: primary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("No Session to Verify",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  "Belum ada sesi yang perlu diverifikasi.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    final mentors = DummyData.mentors;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: primary.withOpacity(0.15),
                    backgroundImage: (_fotoUrl != null && _fotoUrl!.isNotEmpty)
                        ? NetworkImage(_fotoUrl!)
                        : null,
                    child: (_fotoUrl == null || _fotoUrl!.isEmpty)
                        ? Text(
                            _namaUser.isNotEmpty
                                ? _namaUser[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hello 👋",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        _loadingUser
                            ? const SizedBox(
                                height: 18,
                                width: 100,
                                child: LinearProgressIndicator(),
                              )
                            : Text(
                                _namaUser.isNotEmpty ? _namaUser : 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalendarPage())),
                    child: _circleIcon(Icons.calendar_today),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationPage())),
                    child: _circleIcon(Icons.notifications),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SESSION CARD (dinamis dari Supabase)
              /// SESSION CARD (Verify) — selalu tampil
              if (_loadingVerify)
                _loadingCard()
              else if (_verifyCtrl.pendingSessions.isEmpty)
                // Belum ada sesi yang perlu diverifikasi
                _emptyVerifyCard()
              else
                ..._verifyCtrl.pendingSessions.map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primary, primary.withOpacity(0.75)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.verified_rounded,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Session Finished 🎉",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Verifikasi sesi dengan ${session.mentorName}.",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      height: 1.4,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClientVerificationPage(
                                    session: session,
                                  ),
                                ),
                              );
                              if (result == true) {
                                setState(() => _loadingVerify = true);
                                _loadVerifications();
                              }
                            },
                            child: const Text("Verify",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              /// MOTIVATION CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lightbulb, color: primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Level Up Your Skills 🚀",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            "Keep learning today to unlock better opportunities tomorrow.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// TODAY SESSION (dinamis - sesi terdekat dari Supabase)
              /// TODAY SESSION — selalu tampil
              if (_loadingSession)
                _loadingCard()
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _nextSession != null
                              ? Icons.schedule
                              : Icons.event_busy,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _nextSession != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Today Session",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                      "Session with ${_nextSession!.mentorName}"),
                                  Text(
                                    "${_nextSession!.dateLabel} • ${_nextSession!.timeLabel}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Today Session",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(
                                    "Belum ada sesi terjadwal",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              // Jarak setelah kartu (hanya jika kartu muncul)
              if (!_loadingSession && _nextSession != null)
                const SizedBox(height: 25),

              /// MAP
              const Text("Nearby Mentors",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      child: _loadingNearby
                          ? Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _nearbyCtrl.cameraCenter,
                                zoom: 13,
                              ),
                              markers: _nearbyCtrl.markers,
                              zoomControlsEnabled: false,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,

                              // ── Matikan semua gesture (map statis) ──
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,

                              onMapCreated: (controller) {
                                _focusToMentor(controller);
                              },
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _loadingNearby
                              ? "Mencari mentor..."
                              : "${_nearbyCtrl.nearbyCount} Mentors Nearby",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text("Top Mentors",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (_loadingTop)
                const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_topMentorsCtrl.topMentors.isEmpty)
                // Belum ada mentor yang dirating
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("Belum ada Top Mentor",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          "Top mentor muncul setelah ada sesi yang selesai & diberi rating.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topMentorsCtrl.topMentors.length,
                    itemBuilder: (context, index) {
                      final mentor = _topMentorsCtrl.topMentors[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MentorProfilePage(
                                mentorId: mentor.mentorId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                            image: (mentor.fotoUrl != null &&
                                    mentor.fotoUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(mentor.fotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Gradient gelap di bawah supaya teks terbaca
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Rating badge (kiri atas)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: _ratingBox(mentor.avgRating),
                              ),

                              // Inisial kalau tidak ada foto
                              if (mentor.fotoUrl == null ||
                                  mentor.fotoUrl!.isEmpty)
                                Center(
                                  child: Text(
                                    mentor.name.isNotEmpty
                                        ? mentor.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),

                              // Nama + kategori (kiri bawah)
                              Positioned(
                                left: 12,
                                bottom: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mentor.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      mentor.category,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 25),

              /// WHAT THEY SAY (dinamis dari Supabase - tabel reviews)
              const Text("What They Say 💬",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_loadingTestimonial)
                const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_testimonialCtrl.testimonials.isEmpty)
                // Belum ada komentar
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Belum ada komentar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _testimonialCtrl.testimonials.length,
                    itemBuilder: (context, index) {
                      final t = _testimonialCtrl.testimonials[index];
                      return _testimonialCard(t);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: Colors.deepPurple),
    );
  }

  Widget _ratingBox(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _selectedIndex == index ? primary : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _selectedIndex == index ? primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Kartu testimoni (What They Say) — data dari tabel reviews ──
  Widget _testimonialCard(TestimonialModel t) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.1),
                backgroundImage:
                    (t.reviewerFoto != null && t.reviewerFoto!.isNotEmpty)
                        ? NetworkImage(t.reviewerFoto!)
                        : null,
                child: (t.reviewerFoto == null || t.reviewerFoto!.isEmpty)
                    ? Text(
                        t.reviewerName.isNotEmpty
                            ? t.reviewerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.reviewerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(t.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              t.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
