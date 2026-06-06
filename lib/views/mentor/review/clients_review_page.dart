import 'package:flutter/material.dart';
import '../../../controller/mentor/client_review_controller.dart';
import '../../../models/mentor/client_review_model.dart';

class ClientReviewsPage extends StatefulWidget {
  const ClientReviewsPage({super.key});

  @override
  State<ClientReviewsPage> createState() => _ClientReviewsPageState();
}

class _ClientReviewsPageState extends State<ClientReviewsPage> {
  final ClientReviewController _controller = ClientReviewController();
  final TextEditingController _searchController = TextEditingController();

  static const Color _primary = Color(0xFF5B62CC);
  static const List<Color> _accentColors = [
    Color(0xFFF5B3CE),
    Color(0xFFA7C7E7),
    Color(0xFFCDB4DB),
    Color(0xFFB5EAD7),
    Color(0xFFFFDAC1),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tangkap argumen studentName dari landing page
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('studentName')) {
      final name = args['studentName'] as String;
      _controller.searchQuery = name;
      _searchController.text = name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.fetchReviews();
    if (mounted) setState(() {});
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
        actions: [
          if (!_controller.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: _primary),
              onPressed: _load,
            ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _controller.errorMessage != null
              ? _buildError()
              : Column(
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _controller.searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search student...",
                  hintStyle:
                      const TextStyle(fontFamily: 'Nunito', fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _primary),
                  suffixIcon: _controller.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() {
                            _controller.searchQuery = '';
                            _searchController.clear();
                          }),
                        )
                      : null,
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
      onSelected: (val) => setState(() => _controller.selectedStarFilter = val),
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 0, child: Text("All Ratings")),
        PopupMenuItem(value: 5, child: Text("5 Stars Only")),
        PopupMenuItem(value: 4, child: Text("4 Stars Only")),
        PopupMenuItem(value: 3, child: Text("3 Stars Only")),
        PopupMenuItem(value: 2, child: Text("2 Stars Only")),
        PopupMenuItem(value: 1, child: Text("1 Star Only")),
      ],
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          Icons.star_border_rounded,
          color: _controller.selectedStarFilter > 0 ? Colors.amber : _primary,
        ),
      ),
    );
  }

  Widget _buildSortIcon() {
    return GestureDetector(
      onTap: () => setState(
          () => _controller.isNewestFirst = !_controller.isNewestFirst),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          _controller.isNewestFirst
              ? Icons.sort_rounded
              : Icons.history_rounded,
          color: _primary,
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    final list = _controller.filteredReviews;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              _controller.searchQuery.isNotEmpty
                  ? 'No reviews found for "${_controller.searchQuery}"'
                  : 'Belum ada ulasan',
              style: TextStyle(color: Colors.grey[400], fontFamily: 'Nunito'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: list.length,
        itemBuilder: (ctx, i) => _buildReviewCard(list[i], i),
      ),
    );
  }

  Widget _buildReviewCard(ClientReviewModel r, int index) {
    final color = _accentColors[index % _accentColors.length];

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
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: r.clientFotoUrl != null
                    ? ClipOval(
                        child:
                            Image.network(r.clientFotoUrl!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          r.initial,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    if (r.categoryName != null)
                      Text(
                        r.categoryName!,
                        style: TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                  ],
                ),
              ),
              // Bintang rating
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < r.rating ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.reviewText != null && r.reviewText!.isNotEmpty
                ? '"${r.reviewText!}"'
                : '-',
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
            child: Text(
              r.dateTimeLabel,
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
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _controller.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Nunito', color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
