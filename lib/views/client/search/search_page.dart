import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/mentor_model.dart';
import '../profile/mentor_profile_page.dart';

/// MODEL MENTOR
class Mentor {
  final String name;
  final String category;
  final double price;
  final double distance;
  final String image;
  final double rating;

  Mentor({
    required this.name,
    required this.category,
    required this.price,
    required this.distance,
    required this.image,
    required this.rating,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCategory = "All";
  double maxPrice = 100000;
  double maxDistance = 10;

  final List<String> categories = [
    "All",
    "Balet",
    "Produk designer",
    "UX Designer",
    "dance",
  ];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  ///DATA MENTOR (DISAMAIN)
  List<Mentor> allMentors = [
    Mentor(
      name: "Jerome",
      category: "Matematika",
      price: 80000,
      distance: 5,
      image: "assets/mentor1.jpg",
      rating: 4.8,
    ),
    Mentor(
      name: "Belva",
      category: "UX Designer",
      price: 100000,
      distance: 3,
      image: "assets/mentor2.jpg",
      rating: 4.7,
    ),
    Mentor(
      name: "Loey",
      category: "Music",
      price: 60000,
      distance: 7,
      image: "assets/profile.jpg",
      rating: 4.5,
    ),
  ];

  List<Mentor> filteredMentors = [];

  @override
  void initState() {
    super.initState();
    filteredMentors = allMentors;
  }

  /// FILTER
  void applyFilter() {
    setState(() {
      filteredMentors = allMentors.where((mentor) {
        final matchCategory =
            selectedCategory == "All" || mentor.category == selectedCategory;

        final matchPrice = mentor.price <= maxPrice;
        final matchDistance = mentor.distance <= maxDistance;

        return matchCategory && matchPrice && matchDistance;
      }).toList();
    });
  }

  ///NAVIGATE KE PROFILE
  void openProfile(Mentor mentor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MentorProfilePage(
          mentor: MentorModel(
            name: mentor.name,
            category: mentor.category,
            image: mentor.image,
            rating: mentor.rating,
            price: mentor.price.toInt(),
            distance: mentor.distance,
          ),
        ),
      ),
    );
  }

  /// FILTER MODAL (TETAP)
  void _openFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Filter",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  Text("Max Price: ${currencyFormat.format(maxPrice)}"),
                  Slider(
                    value: maxPrice,
                    min: 0,
                    max: 200000,
                    divisions: 20,
                    onChanged: (value) {
                      setModalState(() => maxPrice = value);
                    },
                  ),

                  Text("Distance: ${maxDistance.toInt()} km"),
                  Slider(
                    value: maxDistance,
                    min: 1,
                    max: 50,
                    divisions: 10,
                    onChanged: (value) {
                      setModalState(() => maxDistance = value);
                    },
                  ),

                  ElevatedButton(
                    onPressed: () {
                      applyFilter();
                      Navigator.pop(context);
                    },
                    child: const Text("Apply Filter"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        title: const Text("Search Mentors"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilter,
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH BAR (optional nanti bisa ditambah logic)
            TextField(
              decoration: InputDecoration(
                hintText: "Search Mentors",
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

            /// CATEGORY
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) {
                        setState(() => selectedCategory = cat);
                        applyFilter();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            Text("${filteredMentors.length} Results"),

            const SizedBox(height: 10),

            ///LIST + CLICK
            Expanded(
              child: ListView.builder(
                itemCount: filteredMentors.length,
                itemBuilder: (context, index) {
                  final mentor = filteredMentors[index];

                  return GestureDetector(
                    onTap: () => openProfile(mentor),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(mentor.image),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mentor.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(mentor.category,
                                    style:
                                        const TextStyle(color: Colors.grey)),
                                Text(
                                  "${currencyFormat.format(mentor.price)} • ${mentor.distance} km",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              Text(mentor.rating.toString()),
                            ],
                          )
                        ],
                      ),
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