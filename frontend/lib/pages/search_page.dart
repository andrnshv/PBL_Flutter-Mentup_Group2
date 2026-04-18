import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCategory = "All";
  double maxPrice = 100;
  double maxDistance = 10;

  final List<String> categories = [
    "All",
    "Matematika",
    "Programming",
    "Design",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Search Mentors"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔍 SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search mentor...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🎯 FILTER KATEGORI
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// 💰 FILTER HARGA
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Max Price: \$${maxPrice.toInt()}"),
            ),

            Slider(
              value: maxPrice,
              min: 0,
              max: 200,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  maxPrice = value;
                });
              },
            ),

            const SizedBox(height: 10),

            /// 📍 FILTER LOKASI
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
                setState(() {
                  maxDistance = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// 📋 RESULT (DUMMY)
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(),
                      title: Text("Mentor $index"),
                      subtitle: const Text("Category • Rating 4.8"),
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