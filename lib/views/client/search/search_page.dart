import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// MODEL MENTOR
class Mentor {
  final String name;
  final String category;
  final double price;
  final double distance;

  Mentor({
    required this.name,
    required this.category,
    required this.price,
    required this.distance,
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

  /// FORMAT RUPIAH
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// DATA MENTOR (SUDAH RUPIAH)
  List<Mentor> allMentors = [
    Mentor(name: "Lovie", category: "UX Designer", price: 80000, distance: 5),
    Mentor(name: "Aiska", category: "Balet", price: 50000, distance: 8),
    Mentor(name: "Nabil", category: "Produk designer", price: 120000, distance: 3),
    Mentor(name: "Andrian", category: "UX Designer", price: 60000, distance: 12),
    Mentor(name: "Chanyeol", category: "dance", price: 30000, distance: 2),
  ];

  List<Mentor> filteredMentors = [];

  @override
  void initState() {
    super.initState();
    filteredMentors = allMentors;
  }

  /// FUNCTION FILTER
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

  /// MODAL FILTER
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
                  const Text(
                    "Filter",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// PRICE (RUPIAH)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Max Price: ${currencyFormat.format(maxPrice)}",
                    ),
                  ),
                  Slider(
                    value: maxPrice,
                    min: 0,
                    max: 200000,
                    divisions: 20,
                    onChanged: (value) {
                      setModalState(() {
                        maxPrice = value;
                      });
                    },
                  ),

                  /// DISTANCE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Distance: ${maxDistance.toInt()} km"),
                  ),
                  Slider(
                    value: maxDistance,
                    min: 1,
                    max: 50,
                    divisions: 10,
                    onChanged: (value) {
                      setModalState(() {
                        maxDistance = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// APPLY BUTTON
                  ElevatedButton(
                    onPressed: () {
                      applyFilter();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
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

            /// SEARCH BAR
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
                      selectedColor: Colors.purple.shade100,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                        });
                        applyFilter();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            /// RESULT COUNT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${filteredMentors.length} Results"),
              ],
            ),

            const SizedBox(height: 10),

            /// LIST RESULT
            Expanded(
              child: filteredMentors.isEmpty
                  ? const Center(child: Text("No mentor found."))
                  : ListView.builder(
                      itemCount: filteredMentors.length,
                      itemBuilder: (context, index) {
                        final mentor = filteredMentors[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/profile.jpg'),
                            ),
                            title: Text(mentor.name),
                            subtitle: Text(
                              "${mentor.category} • ${currencyFormat.format(mentor.price)} • ${mentor.distance} km",
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