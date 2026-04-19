import 'package:flutter/material.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  int selectedTab = 0;

  List<Map<String, dynamic>> mentors = [
    {
      "name": "Dummy",
      "role": "UX Designer",
      "image": "assets/profile.jpg",
      "isSaved": false,
    },
    {
      "name": "Dummy",
      "role": "UX Designer",
      "image": "assets/profile.jpg",
      "isSaved": false,
    },
    {
      "name": "Dummy",
      "role": "UX Designer",
      "image": "assets/profile.jpg",
      "isSaved": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List savedMentors =
        mentors.where((m) => m["isSaved"] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Network",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border,
                        color: Colors.purple),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// TAB
              Row(
                children: [
                  _tabItem("Mentors", 0),
                  const SizedBox(width: 20),
                  _tabItem("Saved", 1),
                ],
              ),

              const SizedBox(height: 20),

              /// LIST
              Expanded(
                child: ListView.builder(
                  itemCount: selectedTab == 0
                      ? mentors.length
                      : savedMentors.length,
                  itemBuilder: (context, index) {
                    final data = selectedTab == 0
                        ? mentors[index]
                        : savedMentors[index];

                    return _mentorItem(data);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// TAB ITEM
  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.purple : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 2,
            width: 60,
            color: isActive ? Colors.purple : Colors.transparent,
          )
        ],
      ),
    );
  }

  /// MENTOR ITEM
  Widget _mentorItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          /// FOTO
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(data["image"]),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data["role"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// ACTION
          selectedTab == 0
              ? IconButton(
                  icon: Icon(
                    data["isSaved"]
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    setState(() {
                      data["isSaved"] = !data["isSaved"];
                    });

                    /// 🔥 SNACKBAR PREMIUM
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: data["isSaved"]
                            ? const Color(0xFF6C63FF) // ungu
                            : Colors.redAccent, // merah kalau remove
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        duration: const Duration(seconds: 2),
                        content: Row(
                          children: [
                            Icon(
                              data["isSaved"]
                                  ? Icons.favorite
                                  : Icons.delete,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                data["isSaved"]
                                    ? "${data["name"]} saved ❤️"
                                    : "${data["name"]} removed",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Booking",
                    style: TextStyle(color: Colors.purple),
                  ),
                )
        ],
      ),
    );
  }
}