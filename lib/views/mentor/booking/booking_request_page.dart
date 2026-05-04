import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class BookingRequestPage extends StatefulWidget {
  const BookingRequestPage({super.key});

  @override
  State<BookingRequestPage> createState() => _BookingRequestPageState();
}

class _BookingRequestPageState extends State<BookingRequestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- STATE UNTUK FITUR SEARCH, FILTER, & SORT ---
  String _searchQuery = "";
  String _selectedCategory = "All"; // Default: Menampilkan semua kategori
  bool _isAscending = true;

  final Color primary = const Color(0xFF6C63FF);
  final Color backgroundColor = const Color(0xFFF4F6FA);

  // Data Dummy Master
  final List<Map<String, dynamic>> _allRequests = [
    {
      "name": "Aiska Rahma",
      "cat": "Statistics",
      "date": "21 Apr 2026",
      "time": "09:00",
      "status": "Pending",
      "color": const Color(0xFFF5B3CE),
    },
    {
      "name": "Bima Santoso",
      "cat": "Web Development",
      "date": "22 Apr 2026",
      "time": "13:00",
      "status": "Pending",
      "color": const Color(0xFFA7C7E7),
    },
    {
      "name": "Citra Kirana",
      "cat": "UI/UX Design",
      "date": "23 Apr 2026",
      "time": "15:00",
      "status": "Pending",
      "color": const Color(0xFFCDB4DB),
    },
    {
      "name": "Zidan Pratama",
      "cat": "Database",
      "date": "24 Apr 2026",
      "time": "10:00",
      "status": "Accepted",
      "color": const Color(0xFFA7C7E7),
    },
    // --- INI DATA DUMMY REJECTED BARU ---
    {
      "name": "Riko Saputra",
      "cat": "Mobile Dev",
      "date": "25 Apr 2026",
      "time": "14:00",
      "status": "Rejected",
      "reason":
          "Maaf ya Riko, kebetulan di jam segitu aku ada jadwal bimbingan project dengan dosen. Boleh request ulang untuk jadwal minggu depan aja ya!",
      "color": const Color(0xFFA7C7E7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // --- LOGIKA UTAMA: SEARCHING, FILTERING, & SORTING ---
  List<Map<String, dynamic>> _getFilteredList(String status) {
    // 1. Filter berdasarkan status Tab (Pending/Accepted/Rejected)
    var list = _allRequests.where((item) => item['status'] == status).toList();

    // 2. Filter berdasarkan Pencarian Nama
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) {
        return item['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 3. Filter berdasarkan Kategori (Statistics, Web Dev, dll)
    if (_selectedCategory != "All") {
      list = list.where((item) => item['cat'] == _selectedCategory).toList();
    }

    // 4. Sorting berdasarkan Nama (A-Z atau Z-A)
    list.sort((a, b) {
      int cmp = a['name'].compareTo(b['name']);
      return _isAscending ? cmp : -cmp;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Booking Requests",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // --- BARIS SEARCH, FILTER KATEGORI, & SORT ---
          _buildActionControlBar(),

          // --- TABBAR MODERN ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: primary,
              ),
              labelStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: "Pending"),
                Tab(text: "Accepted"),
                Tab(text: "Rejected"),
              ],
            ),
          ),

          // --- LIST VIEW ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList("Pending"),
                _buildRequestList("Accepted"),
                _buildRequestList("Rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Input Search
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search student...",
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Filter Kategori (Menu Popup)
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _selectedCategory = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All Categories")),
              const PopupMenuItem(
                value: "Statistics",
                child: Text("Statistics"),
              ),
              const PopupMenuItem(
                value: "Web Development",
                child: Text("Web Dev"),
              ),
              const PopupMenuItem(value: "UI/UX Design", child: Text("UI/UX")),
              const PopupMenuItem(value: "Database", child: Text("Database")),
            ],
            child: _buildIconButton(
              _selectedCategory == "All"
                  ? Icons.filter_list_rounded
                  : Icons.filter_alt_rounded,
              _selectedCategory != "All",
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Sort
          GestureDetector(
            onTap: () => setState(() => _isAscending = !_isAscending),
            child: _buildIconButton(
              _isAscending ? Icons.sort_by_alpha_rounded : Icons.sort_rounded,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isActive) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: isActive ? primary : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: isActive ? Colors.white : primary, size: 22),
    );
  }

  Widget _buildRequestList(String status) {
    final displayList = _getFilteredList(status);

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "No match found in $status",
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.bookingDetail,
              arguments: item,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar Pastel dengan inisial
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      item['name'].substring(0, 1),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: item['color'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Badge Kategori (Lebih Hidup)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['cat'],
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Kolom Tanggal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item['date'].split(" ")[0] +
                          " " +
                          item['date'].split(" ")[1],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['time'],
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[200],
                  size: 14,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
