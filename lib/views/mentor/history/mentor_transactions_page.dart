import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controller/mentor/mentor_earnings_controller.dart';
import '../../../models/mentor/mentor_earnings_model.dart';

class MentorTransactionsPage extends StatefulWidget {
  const MentorTransactionsPage({super.key});

  @override
  State<MentorTransactionsPage> createState() =>
      _MentorTransactionsPageState();
}

class _MentorTransactionsPageState extends State<MentorTransactionsPage> {
  final MentorEarningsController _controller = MentorEarningsController();

  static const Color _primary   = Color(0xFF5B62CC);
  static const Color _secondary = Color(0xFFA7C7E7);

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'id', symbol: 'Rp ', decimalDigits: 0,
  );

  // Filter state lokal (untuk slider di bottom sheet)
  late RangeValues _rangeValues;

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
    _rangeValues = const RangeValues(0, 10000000);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await _controller.fetchEarnings();
    if (mounted) {
      // Inisialisasi range slider setelah data ada
      _rangeValues = RangeValues(0, _controller.maxNetAmount);
      _controller.maxAmount = _controller.maxNetAmount;
      setState(() {});
    }
  }

  // ─────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          'Revenue History',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
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
                    _buildHeaderTools(),
                    _buildSummaryCard(),
                    Expanded(child: _buildList()),
                  ],
                ),
    );
  }

  // ─────────────────────────────────────────────────────
  // SEARCH + FILTER + SORT bar
  // ─────────────────────────────────────────────────────
  Widget _buildHeaderTools() {
    final isFiltered = _controller.minAmount > 0 ||
        _controller.maxAmount < _controller.maxNetAmount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // Search
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
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() {
                  _controller.searchQuery = v;
                  _controller.applyFilter();
                }),
                decoration: InputDecoration(
                  hintText: 'Search client...',
                  hintStyle: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: _primary),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter harga
          _iconBtn(
            icon: Icons.tune_rounded,
            color: isFiltered ? Colors.orange : _primary,
            onTap: _showRangePicker,
          ),
          const SizedBox(width: 12),

          // Toggle sort
          _iconBtn(
            icon: _controller.sortByAmount
                ? Icons.payments_rounded
                : Icons.calendar_month_rounded,
            color: _primary,
            onTap: () {
              setState(() {
                _controller.sortByAmount = !_controller.sortByAmount;
                _controller.applyFilter();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            ),
          ],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // SUMMARY CARD — gross, fee, net
  // ─────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total net (besar)
          const Text(
            'Net Revenue',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Nunito',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currency.format(_controller.totalNet),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          // Gross + Fee baris bawah
          Row(
            children: [
              Expanded(
                child: _summaryChip(
                  label: 'Gross',
                  value: _currency.format(_controller.totalGross),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryChip(
                  label: 'Platform Fee',
                  value: _currency.format(_controller.totalFee),
                  isNegative: true,
                ),
              ),
            ],
          ),

          // Count
          const SizedBox(height: 10),
          Text(
            '${_controller.filteredEarnings.length} transaction(s)',
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'Nunito',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required String label,
    required String value,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Nunito',
                  fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            isNegative ? '- $value' : value,
            style: TextStyle(
              color: isNegative
                  ? Colors.red[200]
                  : Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────────────
  Widget _buildList() {
    if (_controller.filteredEarnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No transactions found',
              style: TextStyle(
                  fontFamily: 'Nunito', color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: _controller.filteredEarnings.length,
        itemBuilder: (_, i) =>
            _buildCard(_controller.filteredEarnings[i], i),
      ),
    );
  }

  Widget _buildCard(MentorEarningsModel item, int index) {
    final accent = _accentColors[index % _accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(item, accent),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.clientName ?? 'Unknown Client',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.dateTimeLabel,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Platform fee badge
                Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded,
                        size: 11, color: Colors.red[300]),
                    const SizedBox(width: 2),
                    Text(
                      'Fee: ${_currency.format(item.platformFee)}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.red[300],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Net (yang diterima mentor)
              Text(
                _currency.format(item.netAmount),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: _primary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              // Gross (kecil, abu)
              Text(
                _currency.format(item.grossAmount),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.grey[400],
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(MentorEarningsModel item, Color accent) {
    final name = item.clientName ?? '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: item.clientFotoUrl != null
          ? ClipOval(
              child: Image.network(item.clientFotoUrl!,
                  fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: accent,
                ),
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────
  // RANGE PICKER (bottom sheet)
  // ─────────────────────────────────────────────────────
  void _showRangePicker() {
    final maxVal = _controller.maxNetAmount;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filter by Revenue Range',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              RangeSlider(
                values: _rangeValues,
                min: 0,
                max: maxVal,
                divisions: 20,
                activeColor: _primary,
                labels: RangeLabels(
                  _currency.format(_rangeValues.start),
                  _currency.format(_rangeValues.end),
                ),
                onChanged: (val) {
                  setModal(() => _rangeValues = val);
                },
              ),
              Text(
                '${_currency.format(_rangeValues.start)} — '
                '${_currency.format(_rangeValues.end)}',
                style: const TextStyle(fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModal(() {
                          _rangeValues = RangeValues(0, maxVal);
                        });
                        setState(() {
                          _controller.minAmount = 0;
                          _controller.maxAmount = maxVal;
                          _controller.applyFilter();
                        });
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontFamily: 'Nunito', color: _primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _controller.minAmount = _rangeValues.start;
                          _controller.maxAmount = _rangeValues.end;
                          _controller.applyFilter();
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Apply Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────
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
            style: TextStyle(
                fontFamily: 'Nunito', color: Colors.grey[500]),
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