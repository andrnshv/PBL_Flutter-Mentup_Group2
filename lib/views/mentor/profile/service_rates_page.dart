import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controller/mentor/service_rates_controller.dart';

class ServiceRatesPage extends StatefulWidget {
  const ServiceRatesPage({super.key});

  @override
  State<ServiceRatesPage> createState() => _ServiceRatesPageState();
}

class _ServiceRatesPageState extends State<ServiceRatesPage> {
  final ServiceRatesController _controller = ServiceRatesController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Palette 4 Warna (Lavender, Pink, Blue, Light Blue)
  final Color lavender = const Color(0xFFCDB4DB);
  final Color gradientPink = const Color(0xFFF8B5C5);
  final Color gradientBlue = const Color(0xFFB5D8F7);
  final Color lightBlue = const Color(0xFFA7C7E7);

  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color bgGray = const Color(0xFFF8F9FB);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _build4ColorBackground(),
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAdminNoticeCard(),
                            const SizedBox(height: 15),
                            _buildPolicyNoteCard(),
                            const SizedBox(height: 20),
                            _buildMainRateCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFF6D92CB),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Admin Verification",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6D92CB),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Every transactions will be verified by the admin team. This process usually takes 1x24 hours.",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyNoteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: gradientPink, size: 18),
              const SizedBox(width: 8),
              Text(
                "Important Notes",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: gradientPink,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bulletPoint("The 10% fee covers platform operations."),
          _bulletPoint("Client see the final price after admin fees."),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRateCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Service Rates",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFF7E7BB9),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Hourly Rate",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(),
          const SizedBox(height: 25),
          _buildEarningsPreview(),
          const SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _build4ColorBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lavender, gradientPink, gradientBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "Service Rates",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller.rateController,
      keyboardType: TextInputType.number,
      onChanged: (val) => setState(() => _controller.calculateEarnings(val)),
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w900,
        fontSize: 20,
        color: Color(0xFF7E7BB9),
      ),
      decoration: InputDecoration(
        prefixText: "Rp ",
        suffixText: "/ hour",
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildEarningsPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _rowItem(
            "Your Rate",
            _currencyFormat.format(_controller.currentRate),
          ),
          const SizedBox(height: 10),
          _rowItem(
            "Platform Fee (10%)",
            "- ${_currencyFormat.format(_controller.platformFee)}",
            color: Colors.redAccent,
          ),
          const Divider(height: 24, color: Colors.white),
          _rowItem(
            "You Receive",
            _currencyFormat.format(_controller.netIncome),
            isBold: true,
            color: const Color(0xFF1ABC9C),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [gradientPink, gradientBlue]),
        boxShadow: [
          BoxShadow(
            color: gradientPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Logika Notifikasi Berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Service rates updated successfully!",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1ABC9C), // Warna Hijau Sukses
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 3),
            ),
          );

          // Kembali ke halaman sebelumnya setelah jeda singkat
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Update Rates",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }
}
