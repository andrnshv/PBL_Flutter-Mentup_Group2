import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../../controller/mentor/booking_request_controller.dart';
import '../../../models/mentor/booking_request_model.dart';
import 'booking_detail_page.dart';

class BookingRequestPage extends StatefulWidget {
  const BookingRequestPage({super.key});

  @override
  State<BookingRequestPage> createState() => _BookingRequestPageState();
}

class _BookingRequestPageState extends State<BookingRequestPage>
    with SingleTickerProviderStateMixin {
  final BookingRequestController _controller = BookingRequestController();
  late TabController _tabController;

  static const Color _primary = Color(0xFF6C63FF);
  static const Color _bg = Color(0xFFF4F6FA);

  static const List<String> _tabs = ['Paid', 'Accepted', 'Rejected'];

  // Warna aksen cycling
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
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.fetchRequests();
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────────────
  // ACCEPT langsung dari list (swipe / long-press alternatif)
  // ─────────────────────────────────────────────────────
  Future<void> _quickAccept(BookingRequestModel item) async {
    final error = await _controller.acceptBooking(item.bookingId);
    if (!mounted) return;

    if (error != null) {
      _toast('error', 'Gagal', error);
    } else {
      setState(() {});
      CherryToast.success(
        title: const Text('Diterima',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        description: Text('Booking ${item.clientName} diterima',
            style: const TextStyle(fontFamily: 'Nunito')),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  Future<void> _quickReject(BookingRequestModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Booking?',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: Text('Tolak booking dari ${item.clientName}?',
            style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final error = await _controller.rejectBooking(item.bookingId);
    if (!mounted) return;

    if (error != null) {
      _toast('error', 'Gagal', error);
    } else {
      setState(() {});
      CherryToast.error(
        title: const Text('Ditolak',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        description: Text('Booking ${item.clientName} ditolak',
            style: const TextStyle(fontFamily: 'Nunito')),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    }
  }

  void _toast(String type, String title, String desc) {
    CherryToast.error(
      title: Text(title,
          style: const TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      description: Text(desc, style: const TextStyle(fontFamily: 'Nunito')),
      animationType: AnimationType.fromTop,
      toastPosition: Position.top,
      autoDismiss: true,
    ).show(context);
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
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
                    _buildSearchAndSort(),
                    _buildTabBar(),
                    Expanded(child: _buildTabViews()),
                  ],
                ),
    );
  }

  // ── Search + Sort bar ─────────────────────────────────
  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
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
                onChanged: (v) => setState(() => _controller.searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search student...',
                  hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Colors.grey[400]),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                  suffixIcon: _controller.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () =>
                              setState(() => _controller.searchQuery = ''),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(
                () => _controller.isAscending = !_controller.isAscending),
            child: Container(
              height: 50,
              width: 50,
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
              child: Icon(
                _controller.isAscending
                    ? Icons.sort_by_alpha_rounded
                    : Icons.sort_rounded,
                color: _primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TabBar ────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
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
          color: _primary,
        ),
        labelStyle:
            const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        tabs: _tabs.map((t) {
          final count = _controller.listFor(t).length;
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style:
                          const TextStyle(fontFamily: 'Nunito', fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── TabBarView ────────────────────────────────────────
  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: _tabs.map((t) => _buildList(t)).toList(),
    );
  }

  // ── List per tab ──────────────────────────────────────
  Widget _buildList(String tab) {
    final list = _controller.listFor(tab);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              _controller.searchQuery.isNotEmpty
                  ? 'No match found in $tab'
                  : 'No $tab requests',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i], i),
      ),
    );
  }

  // ── Card item ─────────────────────────────────────────
  Widget _buildCard(BookingRequestModel item, int index) {
    final accent = _accentColors[index % _accentColors.length];

    return GestureDetector(
      onTap: () async {
        // Buka detail — setelah kembali refresh jika ada perubahan
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const BookingDetailPage(),
            settings: RouteSettings(
              arguments: {
                'bookingId': item.bookingId,
                'color': _accentColors[_controller
                        .listFor(_tabs[_tabController.index])
                        .indexOf(item) %
                    _accentColors.length],
              },
            ),
          ),
        );
        if (changed == true && mounted) _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.07),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────
            _buildAvatar(item, accent),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.clientName,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // Badge kategori
                  if (item.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.categoryName!,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: _primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Tanggal + jam
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        item.dateLabel,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        item.timeLabel,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action tombol (hanya Pending) ─────────
            if (item.tabGroup == 'Pending')
              _buildPendingActions(item)
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFDADADA), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BookingRequestModel item, Color accent) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: item.clientFotoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(item.clientFotoUrl!, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                item.clientName.isNotEmpty
                    ? item.clientName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: accent),
              ),
            ),
    );
  }

  /// Tombol Accept + Reject inline untuk tab Pending
  Widget _buildPendingActions(BookingRequestModel item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reject
        GestureDetector(
          onTap: () => _quickReject(item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                color: Colors.redAccent, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        // Accept
        GestureDetector(
          onTap: () => _quickAccept(item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.green, size: 18),
          ),
        ),
      ],
    );
  }

  // ── Error state ───────────────────────────────────────
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
