import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/mentor_model.dart';
import '../profile/mentor_profile_page.dart';
import '../data/dummy_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCategory = "All";
  double maxPrice = 100000;
  String selectedDom = "All";

  final domisili = [
    "All",
    "Malang",
    "Surabaya",
    "Kediri",
    "Solo",
    "Jogja",
  ];

  final categories = DummyData.categories;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<MentorModel> filteredMentors = [];

  /// SEARCH
  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredMentors = DummyData.mentors;
  }

  /// ================= FILTER + SEARCH =================
  void applyFilter() {
    setState(() {
      filteredMentors = DummyData.mentors.where((mentor) {
        final matchCategory =
            selectedCategory == "All" || mentor.category == selectedCategory;

        final matchPrice = mentor.price <= maxPrice;

        final matchDom = selectedDom == "All" || mentor.dom == selectedDom;

        /// SEARCH BERDASARKAN NAMA
        final matchSearch = mentor.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );

        return matchCategory && matchPrice && matchDom && matchSearch;
      }).toList();
    });
  }

  void openProfile(MentorModel mentor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MentorProfilePage(mentor: mentor)),
    );
  }

  /// ================= FILTER MODAL =================
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Text("Max Price: ${currencyFormat.format(maxPrice)}"),

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

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedDom,
                    decoration: const InputDecoration(
                      labelText: "Domisili",
                      border: OutlineInputBorder(),
                    ),
                    items: domisili.map((dom) {
                      return DropdownMenuItem(value: dom, child: Text(dom));
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedDom = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        applyFilter();
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filter"),
                    ),
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

      /// ================= APPBAR =================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Search Mentors"),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _openFilter),
        ],
      ),

      /// ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH
            TextField(
              controller: searchController,
              onChanged: (value) {
                searchQuery = value;
                applyFilter();
              },
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

            /// ================= CATEGORY =================
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

            /// ================= LIST MENTOR =================
            Expanded(
              child: filteredMentors.isEmpty
                  ? const Center(
                      child: Text(
                        "Mentor tidak ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mentor.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        mentor.category,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),

                                      Text(
                                        "${currencyFormat.format(mentor.price)} • ${mentor.dom}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),

                                    Text(mentor.rating.toString()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// ================= RESULT =================
            Text("${filteredMentors.length} Results"),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
