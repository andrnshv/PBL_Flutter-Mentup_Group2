import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controller/client/mentor_search_controller.dart';
import '../../../models/client/mentor_search_model.dart';
import '../profile/mentor_profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MentorSearchController _controller = MentorSearchController();

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;

  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color bgGray = const Color(0xFFF8F9FB);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait<void>([
      _controller.fetchCategories(),
      _controller.fetchMentors(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilter() {
    int tempMaxPrice = _controller.maxPrice;
    String tempAlamat = _controller.selectedAlamat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Filter Mentor",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Max Price",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormat.format(tempMaxPrice),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: primaryPurple,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempMaxPrice.toDouble(),
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    activeColor: primaryPurple,
                    onChanged: (value) {
                      setModal(() => tempMaxPrice = value.toInt());
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Domisili",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: tempAlamat,
                      isExpanded: true, // ← kunci fix overflow
                      underline: const SizedBox(),
                      items: _controller.uniqueAlamatList.map((dom) {
                        return DropdownMenuItem(
                          value: dom,
                          child: Text(
                            dom,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModal(() => tempAlamat = value!);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModal(() {
                              tempMaxPrice = 500000;
                              tempAlamat = 'All';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller.maxPrice = tempMaxPrice;
                              _controller.selectedAlamat = tempAlamat;
                              _controller.applyFilter();
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Apply Filter",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
      backgroundColor: bgGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Search Mentors",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            color: Color(0xFF7E7BB9),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: primaryPurple),
            onPressed: _isLoading ? null : _openFilter,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : _controller.errorMessage != null
              ? _buildError()
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildCategoryChips(),
                      const SizedBox(height: 12),
                      _buildResultCount(),
                      const SizedBox(height: 8),
                      Expanded(child: _buildMentorList()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _controller.searchTextController,
      onChanged: (value) {
        setState(() {
          _controller.searchQuery = value;
          _controller.applyFilter();
        });
      },
      decoration: InputDecoration(
        hintText: "Search mentors by name...",
        hintStyle: const TextStyle(fontFamily: 'Nunito'),
        prefixIcon: Icon(Icons.search_rounded, color: primaryPurple),
        suffixIcon: _controller.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    _controller.searchTextController.clear();
                    _controller.searchQuery = '';
                    _controller.applyFilter();
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _controller.categories[index];
          final isSelected = _controller.selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _controller.selectedCategory = cat;
                _controller.applyFilter();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCount() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "${_controller.filteredMentors.length} mentor ditemukan",
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildMentorList() {
    if (_controller.filteredMentors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "Mentor tidak ditemukan",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Coba ubah filter atau kata kunci",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _controller.filteredMentors.length,
      itemBuilder: (context, index) {
        return _buildMentorCard(_controller.filteredMentors[index]);
      },
    );
  }

  Widget _buildMentorCard(MentorSearchModel mentor) {
    return GestureDetector(
      onTap: () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Mentor"),
      content: Text(mentor.namaLengkap),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Foto profil
            CircleAvatar(
              radius: 28,
              backgroundColor: primaryPurple.withOpacity(0.15),
              backgroundImage: mentor.fotoUrl != null
                  ? NetworkImage(mentor.fotoUrl!)
                  : null,
              child: mentor.fotoUrl == null
                  ? Text(
                      mentor.namaLengkap.isNotEmpty
                          ? mentor.namaLengkap[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: primaryPurple,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Info mentor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor.namaLengkap,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (mentor.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mentor.categoryName!,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          mentor.alamat ?? 'Lokasi tidak tersedia',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mentor.pricePerSession != null
                        ? currencyFormat.format(mentor.pricePerSession)
                        : 'Harga belum diset',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: mentor.pricePerSession != null
                          ? const Color(0xFF5B62CC)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Rating
            if (mentor.rating != null)
              Column(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  Text(
                    mentor.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "Gagal memuat data",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _initData();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Coba lagi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}