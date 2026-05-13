import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MentorTransactionsPage extends StatefulWidget {
  const MentorTransactionsPage({super.key});

  @override
  State<MentorTransactionsPage> createState() => _MentorTransactionsPageState();
}

class _MentorTransactionsPageState extends State<MentorTransactionsPage> {
  final Color primaryColor = const Color(0xFF5B62CC);
  final Color pastelBlue = const Color(0xFFA7C7E7);

  String _searchQuery = "";
  RangeValues _currentRangeValues = const RangeValues(
    0,
    1000000,
  ); // Default 0 - 1jt
  bool _sortByAmount = false; // false = Date, true = Amount

  // DATA DUMMY TRANSAKSI
  final List<Map<String, dynamic>> _allTransactions = [
    {
      "name": "Aiska Rahma",
      "date": "2026-05-10",
      "time": "09:00",
      "amount": 150000,
      "color": const Color(0xFFF5B3CE),
    },
    {
      "name": "Bima Santoso",
      "date": "2026-05-11",
      "time": "13:00",
      "amount": 250000,
      "color": const Color(0xFFA7C7E7),
    },
    {
      "name": "Citra Kirana",
      "date": "2026-05-12",
      "time": "15:00",
      "amount": 100000,
      "color": const Color(0xFFCDB4DB),
    },
    {
      "name": "Deni Setiawan",
      "date": "2026-05-09",
      "time": "10:00",
      "amount": 300000,
      "color": const Color(0xFFF5B3CE),
    },
  ];

  List<Map<String, dynamic>> _getFilteredList() {
    List<Map<String, dynamic>> filtered = _allTransactions.where((item) {
      final matchesSearch = item['name'].toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesPrice =
          item['amount'] >= _currentRangeValues.start &&
          item['amount'] <= _currentRangeValues.end;
      return matchesSearch && matchesPrice;
    }).toList();

    filtered.sort((a, b) {
      if (_sortByAmount) {
        return b['amount'].compareTo(a['amount']); // Harga Tertinggi
      } else {
        return b['date'].compareTo(a['date']); // Tanggal Terbaru
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "Revenue History",
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
      ),
      body: Column(
        children: [
          _buildHeaderTools(),
          _buildTotalRevenueCard(filteredList, currencyFormat),
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) => _buildTransactionCard(
                      filteredList[index],
                      currencyFormat,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTools() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search client...",
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
          _buildFilterButton(),
          const SizedBox(width: 12),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showRangePicker(),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          Icons.tune_rounded,
          color:
              _currentRangeValues.start > 0 || _currentRangeValues.end < 1000000
              ? Colors.orange
              : primaryColor,
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () => setState(() => _sortByAmount = !_sortByAmount),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(
          _sortByAmount ? Icons.payments_rounded : Icons.calendar_month_rounded,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(List list, NumberFormat format) {
    int total = list.fold(0, (sum, item) => sum + (item['amount'] as int));
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, pastelBlue]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Revenue",
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Nunito',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            format.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: data['color'].withOpacity(0.15),
            child: Text(
              data['name'][0],
              style: TextStyle(
                color: data['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${data['date']} • ${data['time']}",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            format.format(data['amount']),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              color: primaryColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _showRangePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter by Revenue Range",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 30),
                  RangeSlider(
                    values: _currentRangeValues,
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    activeColor: primaryColor,
                    labels: RangeLabels(
                      "Rp ${_currentRangeValues.start.round()}",
                      "Rp ${_currentRangeValues.end.round()}",
                    ),
                    onChanged: (val) {
                      setModalState(() => _currentRangeValues = val);
                      setState(() {});
                    },
                  ),
                  Text(
                    "Range: Rp ${_currentRangeValues.start.round()} - Rp ${_currentRangeValues.end.round()}",
                    style: const TextStyle(fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Apply Filter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No transactions found",
        style: TextStyle(fontFamily: 'Nunito', color: Colors.grey[400]),
      ),
    );
  }
}
