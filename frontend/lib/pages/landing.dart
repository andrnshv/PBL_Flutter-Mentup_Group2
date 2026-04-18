import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/user_model.dart';
import '../pages/explore_page.dart';
import '../pages/calendar_page.dart';
import '../pages/search_page.dart';
import '../pages/network_page.dart';
import '../pages/profile_page.dart';
import '../pages/notification_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  int _selectedIndex = 0;

  static const LatLng _center = LatLng(-7.9425, 112.6131);
  final Color primary = const Color(0xFF6C63FF);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      _homeContent(),
      const SearchPage(),
      const NetworkPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      /// 🔥 BODY PAKAI INDEXED STACK
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      /// 🔥 BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.search, "Search", 1),
            _navItem(Icons.people, "Network", 2),
            _navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  /// 🔥 HOME CONTENT (PINDAHAN DARI BODY)
  Widget _homeContent() {

    List<UserModel> mentors = [
      UserModel(
        username: "jerome123",
        token: "dummy_token",
        name: "Jerome",
        image: "assets/mentor1.jpg",
        rating: 4.8,
        role: "Matematika",
        category: "Education",
        price: 50000,
        distance: 1.2,
      ),
      UserModel(
        username: "belva123",
        token: "dummy_token",
        name: "Belva",
        image: "assets/mentor2.jpg",
        rating: 4.9,
        role: "Mobile Developer",
        category: "Technology",
        price: 75000,
        distance: 2.5,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarPage(),
                        ),
                      );
                    },
                    child: _circleIcon(Icons.calendar_today),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                    child: _circleIcon(Icons.notifications),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                "Hello, Chanyeol 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// EXPLORE BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExplorePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Explore Mentors",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SESSION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 70,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Session for today",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text("Session with Albert"),
                          const SizedBox(height: 4),
                          const Text(
                            "Today, 11:00 - 10:30 am",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// MAP
              const Text("Maps Area", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 180,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    markers: {
                      const Marker(
                        markerId: MarkerId('main_loc'),
                        position: _center,
                      ),
                    },
                    zoomControlsEnabled: false,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Top mentors for you",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              /// MENTOR LIST
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(mentors[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: _ratingBox(mentors[index].rating),
                          ),
                          const Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(Icons.favorite_border, color: Colors.white),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mentors[index].name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    mentors[index].role,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
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
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
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
          Text(
            rating.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 🔥 NAVIGATION (TIDAK PINDAH PAGE)
  Widget _navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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
}