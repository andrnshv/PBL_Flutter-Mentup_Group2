import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final Color primary = const Color(0xFF6C63FF);

  String selectedCategory = "All";
  String searchQuery = "";

  List<String> categories = ["All", "Technology", "Education", "Design"];

  List<UserModel> mentors = [
    UserModel(
      username: "1",
      token: "x",
      name: "Jerome",
      image: "assets/mentor1.jpg",
      rating: 4.8,
      role: "Matematika",
      category: "Education",
      price: 50000,
      distance: 1.2,
    ),
    UserModel(
      username: "2",
      token: "x",
      name: "Belva",
      image: "assets/mentor2.jpg",
      rating: 4.9,
      role: "Mobile Dev",
      category: "Technology",
      price: 75000,
      distance: 2.5,
    ),
    UserModel(
      username: "3",
      token: "x",
      name: "Alya",
      image: "assets/mentor1.jpg",
      rating: 4.7,
      role: "UI/UX Designer",
      category: "Design",
      price: 60000,
      distance: 3.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<UserModel> filteredMentors = mentors.where((mentor) {
      final matchCategory =
          selectedCategory == "All" || mentor.category == selectedCategory;

      final matchSearch = mentor.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Explore Mentors",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 SEARCH BAR
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search mentor...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🎯 FILTER CATEGORY
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// 📋 LIST MENTOR
            Expanded(
              child: ListView.builder(
                itemCount: filteredMentors.length,
                itemBuilder: (context, index) {
                  final mentor = filteredMentors[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        /// IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            mentor.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// NAME
                              Text(
                                mentor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                mentor.role,
                                style: const TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 6),

                              /// RATING & DISTANCE
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  Text("${mentor.rating}"),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  Text("${mentor.distance} km"),
                                ],
                              ),

                              const SizedBox(height: 6),

                              /// PRICE
                              Text(
                                "Rp ${mentor.price}",
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// FAVORITE
                        const Icon(Icons.favorite_border),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
