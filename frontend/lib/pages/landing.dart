import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user_model.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  static const LatLng _center = LatLng(-7.9425, 112.6131);
  final Color primary = const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    List<UserModel> mentors = [
      UserModel(
        username: "jerome123",
        token: "dummy_token",
        name: "Jerome",
        image: "assets/mentor1.jpg",
      ),
      UserModel(
        username: "belva123",
        token: "dummy_token",
        name: "Belva",
        image: "assets/mentor2.jpg",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔥 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hello, Chanyeol 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _circleIcon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        _circleIcon(Icons.notifications),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔥 BUTTON
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        "Update Profile",
                        style: TextStyle(color: primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 SESSION CARD (UPGRADE)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
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

                /// 🔥 MAP
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

                /// 🔥 MENTOR
                const Text("Top mentors for you",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),

                SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mentors.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            )
                          ],
                          image: DecorationImage(
                            image: AssetImage(mentors[index].image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.favorite_border,
                                  color: Colors.white),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  mentors[index].name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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
      ),

      /// 🔥 FLOATING MODERN NAVBAR
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", true),
            _navItem(Icons.search, "Search", false),
            _navItem(Icons.people, "Network", false),
            _navItem(Icons.person, "Profile", false),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Icon(icon, size: 18, color: primary),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? primary : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? primary : Colors.grey,
          ),
        ),
      ],
    );
  }
}