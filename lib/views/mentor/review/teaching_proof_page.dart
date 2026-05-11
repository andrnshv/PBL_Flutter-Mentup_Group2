import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_routes.dart';

class TeachingProofPage extends StatefulWidget {
  const TeachingProofPage({super.key});

  @override
  State<TeachingProofPage> createState() => _TeachingProofPageState();
}

class _TeachingProofPageState extends State<TeachingProofPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- STATE UNTUK FITUR SEARCH, FILTER, SORT, & EXPAND ---
  String _searchQuery = "";
  String _selectedCategory = "All";
  bool _isAscending = true;
  String? _expandedSessionId;

  // --- STATE UNTUK GALERI ---
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  final Color primaryColor = const Color(0xFF5B62CC);
  final Color pastelPink = const Color(0xFFF5B3CE);
  final Color pastelBlue = const Color(0xFFA7C7E7);
  final Color pastelLavender = const Color(0xFFCDB4DB);

  // DATA MASTER
  final List<Map<String, dynamic>> _allSessions = [
    {
      "name": "Aiska Rahma",
      "cat": "Statistics",
      "date": "2026-04-21",
      "time": "09:00",
      "status": "Pending Proof",
      "color": const Color(0xFFF5B3CE),
    },
    {
      "name": "Bima Santoso",
      "cat": "Web Development",
      "date": "2026-04-22",
      "time": "13:00",
      "status": "Pending Verification",
      "color": const Color(0xFFA7C7E7),
    },
    {
      "name": "Citra Kirana",
      "cat": "UI/UX Design",
      "date": "2026-04-23",
      "time": "15:00",
      "status": "Completed",
      "color": const Color(0xFFCDB4DB),
    },
    {
      "name": "Deni Setiawan",
      "cat": "Statistics",
      "date": "2026-04-20",
      "time": "10:00",
      "status": "Pending Proof",
      "color": const Color(0xFFF5B3CE),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Map<String, dynamic>> _getFilteredList(String status) {
    List<Map<String, dynamic>> filtered = _allSessions.where((item) {
      final matchesStatus = item['status'] == status;
      final matchesSearch = item['name'].toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCat =
          _selectedCategory == "All" || item['cat'] == _selectedCategory;
      return matchesStatus && matchesSearch && matchesCat;
    }).toList();

    filtered.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          "Teaching Proof",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildTopTools(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListByStatus("Pending Proof"),
                _buildListByStatus("Pending Verification"),
                _buildListByStatus("Completed"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTools() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search student...",
                  hintStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.search, color: primaryColor, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _selectedCategory = val),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 55),
            itemBuilder: (context) =>
                ["All", "Statistics", "Web Development", "UI/UX Design"]
                    .map(
                      (cat) => PopupMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: _selectedCategory == cat
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: _selectedCategory == cat
                                ? primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.tune_rounded, color: primaryColor),
                ),
                if (_selectedCategory != "All")
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () => setState(() => _isAscending = !_isAscending),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isAscending ? Icons.sort_rounded : Icons.sort_by_alpha_rounded,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: "Required"),
          Tab(text: "In Review"),
          Tab(text: "Verified"),
        ],
      ),
    );
  }

  Widget _buildListByStatus(String status) {
    final list = _getFilteredList(status);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 15),
            Text(
              "No sessions found",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildExpandableProofCard(list[index]);
      },
    );
  }

  Widget _buildExpandableProofCard(Map<String, dynamic> session) {
    bool isExpanded = _expandedSessionId == session['name'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExpanded
              ? primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() {
              _expandedSessionId = isExpanded ? null : session['name'];
              _capturedImage = null; // Reset foto jika pindah card
            }),
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: session['color'].withOpacity(0.2),
              child: Text(
                session['name'][0],
                style: TextStyle(
                  color: session['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              session['name'],
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  session['cat'],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${session['date']} • ${session['time']}",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildStatusChip(session['status']),
          ),
          if (isExpanded) _buildExpansionContent(session),
        ],
      ),
    );
  }

  Widget _buildExpansionContent(Map<String, dynamic> session) {
    if (session['status'] == "Pending Proof") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const Divider(height: 30),
            _buildUploadZone(),
            const SizedBox(height: 15),
            _buildSummaryInput(),
            const SizedBox(height: 20),
            _buildSubmitAction(),
          ],
        ),
      );
    } else {
      return _buildViewOnlyStatus(session);
    }
  }

  // --- REVISI: FUNGSI GALERI ---
  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: () async {
        // PERUBAHAN DI SINI: Dari ImageSource.camera menjadi ImageSource.gallery
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (photo != null) {
          setState(() {
            _capturedImage = File(photo.path);
          });
        }
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: pastelBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: pastelBlue.withOpacity(0.5), width: 1.5),
          image: _capturedImage != null
              ? DecorationImage(
                  image: FileImage(_capturedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _capturedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon dan Teks disesuaikan untuk Galeri
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    color: primaryColor,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Upload Session Photo",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tap to open gallery",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      onPressed: () => setState(() => _capturedImage = null),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryInput() {
    return TextField(
      maxLines: 2,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
      decoration: InputDecoration(
        hintText: "What was discussed? (Optional)",
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitAction() {
    return ElevatedButton(
      onPressed: () {
        if (_capturedImage == null) {
          CherryToast.error(
            title: const Text(
              "Proof Required",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            description: const Text(
              "You must attach a session photo!",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
            autoDismiss: true,
          ).show(context);
          return;
        }

        CherryToast.success(
          title: const Text(
            "Success",
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
          description: const Text(
            "Proof has been sent to client for verification.",
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          onToastClosed: () => setState(() {
            _expandedSessionId = null;
            _capturedImage = null;
          }),
        ).show(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: const Text(
        "Submit Teaching Proof",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // REVISI: Terima map session lalu pass namanya sebagai argument
  Widget _buildViewOnlyStatus(Map<String, dynamic> session) {
    bool isDone = session['status'] == "Completed";
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.fromLTRB(20, 0, 20, isDone ? 10 : 20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                color: isDone ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDone
                      ? "Session verified. You've earned the fee for this session!"
                      : "Waiting for client to verify your submission.",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (isDone)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: OutlinedButton.icon(
              onPressed: () {
                // REVISI PENTING: Melempar Argumen Nama Mahasiswa
                Navigator.pushNamed(
                  context,
                  AppRoutes.clientReviews,
                  arguments: {'studentName': session['name']},
                );
              },
              icon: const Icon(Icons.star_rounded, color: Colors.amber),
              label: Text(
                "View Client Rating",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor.withOpacity(0.4)),
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == "Completed"
        ? Colors.green
        : (status == "Pending Proof" ? pastelPink : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
