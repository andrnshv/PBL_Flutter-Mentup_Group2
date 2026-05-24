import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controller/client/payment_controller.dart';
import '../../../services/duitku_service.dart';

// ================================================================
//  PAYMENT PAGE — MentUp
//  File: lib/views/client/profile/payment_page.dart
//
//  Halaman ini punya 2 mode:
//  1. Mode ringkasan  → tampil daftar transaksi dari Supabase
//  2. Mode WebView    → buka halaman bayar Duitku (muncul otomatis
//                       saat ada bookingId yang dikirim)
//
//  Cara buka dari booking_page.dart (mode bayar langsung):
//    Navigator.push(context, MaterialPageRoute(
//      builder: (_) => PaymentPage(
//        bookingId:   booking['id'],
//        amount:      150000,
//        mentorName:  'Budi Santoso',
//      ),
//    ));
//
//  Cara buka dari profile (mode riwayat saja):
//    Navigator.push(context, MaterialPageRoute(
//      builder: (_) => const PaymentPage(),
//    ));
// ================================================================

class PaymentPage extends StatefulWidget {
  /// Isi parameter ini saat membuka dari halaman booking
  /// Kosongkan jika hanya ingin lihat riwayat transaksi
  final String? bookingId;
  final int? amount;
  final String? mentorName;

  const PaymentPage({
    super.key,
    this.bookingId,
    this.amount,
    this.mentorName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _supabase = Supabase.instance.client;
  final _ctrl = PaymentController();

  // State riwayat transaksi
  List<Map<String, dynamic>> _transactions = [];
  bool _loadingHistory = false;

  // State WebView Duitku
  WebViewController? _webCtrl;
  bool _webLoading = false;
  bool _showWebView = false;
  String? _merchantOrderId;

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    // Kalau ada bookingId → langsung mulai proses bayar
    if (widget.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startPayment());
    }
  }

  // ──────────────────────────────────────────────
  //  LOAD RIWAYAT TRANSAKSI dari Supabase
  //  Join: payments → bookings → bio_profil (mentor)
  // ──────────────────────────────────────────────
  Future<void> _loadTransactions() async {
    setState(() => _loadingHistory = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Ambil payments milik klien ini lewat relasi bookings
      final data = await _supabase
          .from('payments')
          .select('''
            id,
            amount,
            payment_method,
            payment_status,
            paid_at,
            created_at,
            transaction_id,
            bookings (
              id,
              booking_status,
              created_at,
              mentor_id,
              bio_profil!bookings_mentor_id_fkey (
                nama_lengkap,
                foto_url
              ),
              mentor_schedules (
                available_date,
                start_time,
                end_time
              )
            )
          ''')
          .eq('bookings.client_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _transactions = List<Map<String, dynamic>>.from(data);
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() => _loadingHistory = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat transaksi: $e')),
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  //  MULAI PROSES PEMBAYARAN ke Duitku
  // ──────────────────────────────────────────────
  Future<void> _startPayment() async {
    if (widget.bookingId == null || widget.amount == null) return;

    // Ambil data klien dari Supabase
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final userRow = await _supabase
        .from('appuser')
        .select('nama_lengkap, email')
        .eq('id', userId)
        .single();

    final bioRow = await _supabase
        .from('bio_profil')
        .select('nomor_hp')
        .eq('user_id', userId)
        .maybeSingle();

    // merchantOrderId: UUID tanpa tanda hubung, ambil 20 karakter
    _merchantOrderId = widget.bookingId!.replaceAll('-', '').substring(0, 20);

    final url = await _ctrl.createPayment(
      bookingId: widget.bookingId!,
      amount: widget.amount!,
      mentorName: widget.mentorName ?? 'Mentor',
      clientEmail: userRow['email'] ?? '',
      clientName: userRow['nama_lengkap'] ?? '',
      clientPhone: bioRow?['nomor_hp'] ?? '081234567890',
    );

    if (url != null && mounted) {
      _openWebView(url);
    }
  }

  // ──────────────────────────────────────────────
  //  BUKA WEBVIEW dengan URL dari Duitku
  // ──────────────────────────────────────────────
  void _openWebView(String url) {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _webLoading = true),
        onPageFinished: (_) => setState(() => _webLoading = false),
        onNavigationRequest: (req) {
          // Tangkap deep link mentup:// atau returnUrl yang sudah selesai
          if (req.url.startsWith('mentup://') ||
              req.url.contains('payment/return')) {
            _handlePaymentReturn();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));

    setState(() => _showWebView = true);
  }

  // ──────────────────────────────────────────────
  //  HANDLE KEMBALI dari halaman bayar Duitku
  //  → verifikasi status → update DB → tampil dialog
  // ──────────────────────────────────────────────
  Future<void> _handlePaymentReturn() async {
    if (_merchantOrderId == null || widget.bookingId == null) return;

    setState(() => _showWebView = false);

    final status = await _ctrl.verifyPayment(
      bookingId: widget.bookingId!,
      merchantOrderId: _merchantOrderId!,
    );

    if (!mounted) return;

    // Reload riwayat setelah verifikasi
    await _loadTransactions();

    switch (status) {
      case 'paid':
        _showResultDialog(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF27AE60),
          title: 'Pembayaran Berhasil!',
          message: 'Booking kamu sudah dikonfirmasi.\nSelamat belajar! 🎉',
          onClose: () => Navigator.popUntil(context, (r) => r.isFirst),
        );
        break;
      case 'pending':
        _showResultDialog(
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFF39C12),
          title: 'Menunggu Pembayaran',
          message:
              'Pembayaran belum diterima.\nSelesaikan sebelum invoice expired.',
          onClose: () => Navigator.pop(context),
        );
        break;
      default:
        _showResultDialog(
          icon: Icons.cancel_outlined,
          color: const Color(0xFFE74C3C),
          title: 'Pembayaran Gagal',
          message: 'Transaksi tidak berhasil.\nSilakan coba kembali.',
          onClose: () => Navigator.pop(context),
        );
    }
  }

  void _showResultDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 72),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onClose,
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  HELPER: format Rupiah
  // ──────────────────────────────────────────────
  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp -';
    final number = (amount as num).toInt();
    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  // ──────────────────────────────────────────────
  //  HELPER: format tanggal
  // ──────────────────────────────────────────────
  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')} '
          '${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  String _monthName(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m];
  }

  // ──────────────────────────────────────────────
  //  HELPER: status chip
  // ──────────────────────────────────────────────
  Widget _statusChip(String? status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'paid':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF27AE60);
        label = 'Paid';
        break;
      case 'pending':
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF39C12);
        label = 'Pending';
        break;
      case 'failed':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFE74C3C);
        label = 'Failed';
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        fg = Colors.grey;
        label = 'Refunded';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ══════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView ? 'Pembayaran' : 'Payment & Billing'),
        centerTitle: true,
        actions: [
          if (_showWebView && _webCtrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webCtrl!.reload(),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          // ── Mode 1: Loading buat invoice ──────
          if (_ctrl.isLoading && !_showWebView) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyiapkan halaman pembayaran...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // ── Mode 2: Error dari Duitku ─────────
          if (_ctrl.errorMessage != null && !_showWebView) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_ctrl.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: () {
                        _ctrl.reset();
                        _startPayment();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Mode 3: WebView Duitku ────────────
          if (_showWebView && _webCtrl != null) {
            return Stack(
              children: [
                WebViewWidget(controller: _webCtrl!),
                if (_webLoading || _ctrl.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          // ── Mode 4: Halaman ringkasan (default) ──
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Payment Method card ───────────
              const Text('Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: Color(0xFF2E86C1)),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duitku Payment Gateway',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Virtual Account, QRIS, E-Wallet',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Transactions ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transactions',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_loadingHistory)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    GestureDetector(
                      onTap: _loadTransactions,
                      child: const Icon(Icons.refresh,
                          size: 18, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Empty state ───────────────────
              if (!_loadingHistory && _transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Belum ada transaksi',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

              // ── List transaksi dari Supabase ──
              ..._transactions.map((item) {
                final booking = item['bookings'] as Map<String, dynamic>?;
                final bio = booking?['bio_profil'] as Map<String, dynamic>?;
                final schedule =
                    booking?['mentor_schedules'] as Map<String, dynamic>?;

                final mentorName = bio?['nama_lengkap'] ?? 'Mentor';
                final tanggal = _formatDate(
                    schedule?['available_date'] ?? item['created_at']);
                final amount = _formatRupiah(item['amount']);
                final status = item['payment_status'] as String?;
                final method =
                    (item['payment_method'] as String? ?? '').toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar / icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xFF2E86C1)),
                      ),
                      const SizedBox(width: 12),

                      // Info transaksi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mentorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(tanggal,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            if (method.isNotEmpty)
                              Text(method,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),

                      // Amount + status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(amount,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          _statusChip(status),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
