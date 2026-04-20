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
    "Balet",
    "Produk designer",
    "UX Designer",
  ];

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
                  /// TITLE
                  const Text(
                    "Filter",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// PRICE
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

                  /// BUTTON
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // apply filter
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
            onPressed: _openFilter, //buka filter model
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔍 SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search Mentors",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.close),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🎯 CATEGORY CHIP
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
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            /// RESULT COUNT + ICON FILTER KECIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("100+ Results"),
              ],
            ),

            /// 📋 LIST RESULT
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    title: const Text("Aiska Oca ID"),
                    subtitle: const Text(
                        "Designer Manager, Amazon Prime | Tech industry"),
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
