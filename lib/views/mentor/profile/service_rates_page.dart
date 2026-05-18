import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
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
  void initState() {
    super.initState();
    // Simulasi memuat tarif yang sudah ada sebelumnya dari backend
    // Idealnya ini diisi oleh _controller dari database
    _controller.currentRate = 50000; // Contoh tarif saat ini
  }

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
          // MEMANGGIL FUNGSI BACKGROUND YANG BARU
          _buildSettingsGradientBackground(),
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
          _bulletPoint("The rate you set here is your clean hourly rate."),
          _bulletPoint(
            "Platform fees (10%) will be charged separately to the client during booking.",
          ),
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

          // --- INFO: TARIF SAAT INI ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Active Rate",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(_controller.currentRate),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5B62CC),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1ABC9C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Active",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1ABC9C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // --- FORM: SET TARIF BARU ---
          const Text(
            "Set New Hourly Rate",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _buildTextField(),
          const SizedBox(height: 35),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // REVISI: FUNGSI BACKGROUND BARU SESUAI PERMINTAAN
  Widget _buildSettingsGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFCDB4DB), // Lavender
            Color(0xFFA7C7E7), // Light Blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: LinePatternPainter(), // Pattern dari Settings Page
              ),
            ),
          ),
        ],
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
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w900,
        fontSize: 20,
        color: Color(0xFF7E7BB9),
      ),
      decoration: InputDecoration(
        prefixText: "Rp ",
        suffixText: "/ hour",
        hintText: "Enter new rate",
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
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

  // REVISI: WARNA TOMBOL MENYESUAIKAN PRIMARY PURPLE
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primaryPurple, // Warna solid menyesuaikan tema settings
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Validasi jika kosong
          if (_controller.rateController.text.trim().isEmpty) {
            CherryToast.warning(
              title: const Text(
                "Rate is Empty",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
              description: const Text(
                "Please enter your new service rate.",
                style: TextStyle(fontFamily: 'Nunito'),
              ),
              animationType: AnimationType.fromTop,
              toastPosition: Position.top,
              autoDismiss: true,
            ).show(context);
            return;
          }

          // Update UI state tarif saat ini (Simulasi backend sukses)
          setState(() {
            _controller.calculateEarnings(_controller.rateController.text);
            _controller.rateController.clear(); // Bersihkan form
          });

          // Panggil CherryToast untuk success
          CherryToast.success(
            title: const Text(
              "Rates Updated",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
            description: const Text(
              "Your service rates have been successfully saved!",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
            autoDismiss: true,
          ).show(context);
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

// CLASS TAMBAHAN UNTUK BACKGROUND LINE PATTERN
class LinePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 25) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
