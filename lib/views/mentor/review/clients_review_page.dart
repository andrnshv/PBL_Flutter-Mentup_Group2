import 'package:flutter/material.dart';

class ClientReviewsPage extends StatefulWidget {
  const ClientReviewsPage({super.key});

  @override
  State<ClientReviewsPage> createState() => _ClientReviewsPageState();
}

class _ClientReviewsPageState extends State<ClientReviewsPage> {
  final Color primaryColor = const Color(0xFF5B62CC);

  // Controller untuk otomatisasi pencarian dari halaman sebelumnya
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedStarFilter = 0; // 0 artinya All
  bool _isNewestFirst = true;

  // DATA MASTER REVIEW: Sudah kutambahkan 'time'
  final List<Map<String, dynamic>> _allReviews = [
    {
      "name": "Aiska Rahma",
      "cat": "Statistics",
      "date": "2026-04-21",
      "time": "11:00",
      "rating": 5,
      "comment":
          "Penjelasannya sangat mudah dimengerti! Kak Lovie sabar banget ngajarin konsep hipotesis.",
      "color": const Color(0xFFF5B3CE),
    },
    {
      "name": "Bima Santoso",
      "cat": "Web Development",
      "date": "2026-04-22",
      "time": "15:00",
      "rating": 4,
      "comment":
          "Keren banget materinya, langsung praktek bikin Flexbox. Cuman internetku agak lemot tadi.",
      "color": const Color(0xFFA7C7E7),
    },
    {
      "name": "Citra Kirana",
      "cat": "UI/UX Design",
      "date": "2026-04-23",
      "time": "17:00",
      "rating": 5,
      "comment": "Design system yang diajarin kak Lovie rapi banget. Puas bgt!",
      "color": const Color(0xFFCDB4DB),
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MENANGKAP ARGUMEN (Nama Mahasiswa)
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('studentName')) {
      _searchQuery = args['studentName'];
      _searchController.text = args['studentName'];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredReviews() {
    List<Map<String, dynamic>> filtered = _allReviews.where((item) {
      final matchesSearch = item['name'].toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesStars =
          _selectedStarFilter == 0 || item['rating'] == _selectedStarFilter;
      return matchesSearch && matchesStars;
    }).toList();

    filtered.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "Client Reviews",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeaderTools(),
          Expanded(child: _buildReviewList()),
        ],
      ),
    );
  }

  Widget _buildHeaderTools() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: TextField(
                controller:
                    _searchController, // Terhubung ke Controller argumen
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search student...",
                  hintStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterIcon(),
          const SizedBox(width: 12),
          _buildSortIcon(),
        ],
      ),
    );
  }

  Widget _buildFilterIcon() {
    return PopupMenuButton<int>(
      onSelected: (val) => setState(() => _selectedStarFilter = val),
      // REVISI: Menambahkan Filter 3, 2, 1 Bintang
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 0, child: Text("All Ratings")),
        const PopupMenuItem(value: 5, child: Text("5 Stars Only")),
        const PopupMenuItem(value: 4, child: Text("4 Stars Only")),
        const PopupMenuItem(value: 3, child: Text("3 Stars Only")),
        const PopupMenuItem(value: 2, child: Text("2 Stars Only")),
        const PopupMenuItem(value: 1, child: Text("1 Star Only")),
      ],
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          Icons.star_border_rounded,
          color: _selectedStarFilter > 0 ? Colors.amber : primaryColor,
        ),
      ),
    );
  }

  Widget _buildSortIcon() {
    return GestureDetector(
      onTap: () => setState(() => _isNewestFirst = !_isNewestFirst),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          _isNewestFirst ? Icons.sort_rounded : Icons.history_rounded,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    final list = _getFilteredReviews();

    if (list.isEmpty) {
      return Center(
        child: Text(
          "No reviews found.",
          style: TextStyle(color: Colors.grey[400], fontFamily: 'Nunito'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final r = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: r['color'].withOpacity(0.2),
                    child: Text(
                      r['name'][0],
                      style: TextStyle(
                        color: r['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Text(
                          r['cat'],
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: index < r['rating']
                            ? Colors.amber
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                r['comment'],
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                // REVISI: Menampilkan Tanggal dan Waktu (Jam)
                child: Text(
                  "${r['date']} • ${r['time']}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
