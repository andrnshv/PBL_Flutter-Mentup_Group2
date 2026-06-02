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

  // State retry / cancel
  String? _retryBookingId; // booking yang sedang dilanjutkan bayarnya
  String? _processingId; // booking yang sedang diproses (untuk loading kartu)

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

      // 1. Ambil payments + bookings + schedules
      //    (TANPA join bio_profil — FK bookings.mentor_id sekarang
      //     menunjuk ke appuser, bukan bio_profil)
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
            bookings!inner (
              id,
              booking_status,
              created_at,
              mentor_id,
              client_id,
              mentor_schedules (
                available_date,
                start_time,
                end_time
              )
            )
          ''')
          .eq('bookings.client_id', userId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(data);

      // 2. Kumpulkan mentor_id unik
      final mentorIds = <String>{};
      for (final item in list) {
        final b = item['bookings'] as Map<String, dynamic>?;
        final mid = b?['mentor_id'] as String?;
        if (mid != null) mentorIds.add(mid);
      }

      // 3. Ambil data mentor dari bio_profil (user_id = mentor_id)
      final Map<String, Map<String, dynamic>> mentorMap = {};
      if (mentorIds.isNotEmpty) {
        final bios = await _supabase
            .from('bio_profil')
            .select('user_id, nama_lengkap, foto_url')
            .inFilter('user_id', mentorIds.toList());

        for (final bio in List<Map<String, dynamic>>.from(bios)) {
          mentorMap[bio['user_id'] as String] = bio;
        }
      }

      // 4. Tempelkan info mentor ke tiap transaksi (key: _mentor)
      for (final item in list) {
        final b = item['bookings'] as Map<String, dynamic>?;
        final mid = b?['mentor_id'] as String?;
        item['_mentor'] = (mid != null) ? mentorMap[mid] : null;
      }

      setState(() {
        _transactions = list;
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
    // bookingId bisa dari mode bayar awal (widget.bookingId)
    // atau dari mode retry (_retryBookingId)
    final activeBookingId = _retryBookingId ?? widget.bookingId;
    if (_merchantOrderId == null || activeBookingId == null) return;

    setState(() => _showWebView = false);

    final status = await _ctrl.verifyPayment(
      bookingId: activeBookingId,
      merchantOrderId: _merchantOrderId!,
    );

    if (!mounted) return;

    // Reset retry tracking
    _retryBookingId = null;

    // Reload riwayat setelah verifikasi
    await _loadTransactions();

    switch (status) {
      case 'paid':
        _showResultDialog(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF27AE60),
          title: 'Pembayaran Berhasil!',
          message: 'Booking kamu sudah dikonfirmasi.\nSelamat belajar! 🎉',
          onClose: () => Navigator.pop(context),
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

  // ──────────────────────────────────────────────
  //  BAYAR SEKARANG (retry) — lanjutkan pembayaran
  //  untuk booking yang masih pending
  // ──────────────────────────────────────────────
  Future<void> _retryPayment(Map<String, dynamic> item) async {
    final booking = item['bookings'] as Map<String, dynamic>?;
    final bio = item['_mentor'] as Map<String, dynamic>?;
    final bookingId = booking?['id'] as String?;
    final amount = (item['amount'] as num?)?.toInt() ?? 0;
    final mentorName = bio?['nama_lengkap'] ?? 'Mentor';
    if (bookingId == null) return;

    setState(() => _processingId = bookingId);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

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

      final clientName = userRow['nama_lengkap'] as String? ?? 'Klien';
      final clientEmail = userRow['email'] as String? ?? '';
      final clientPhone = bioRow?['nomor_hp'] as String? ?? '08100000000';

      // merchantOrderId BARU & unik (Duitku tolak orderId duplikat)
      final base = bookingId.replaceAll('-', '');
      final suffix = DateTime.now().millisecondsSinceEpoch.toString();
      final orderId = '${base.substring(0, 8)}$suffix'; // < 50 char
      _merchantOrderId = orderId;
      _retryBookingId = bookingId;

      // Buat invoice baru langsung via DuitkuService
      final invoice = await DuitkuService.createInvoice(
        merchantOrderId: orderId,
        paymentAmount: amount,
        productDetails: 'Mentoring bersama $mentorName',
        email: clientEmail,
        phoneNumber: clientPhone,
        customerName: clientName,
        returnUrl: 'mentup://payment/return',
        // Ganti dengan URL Edge Function Supabase kamu:
        callbackUrl:
            'https://YOUR_PROJECT.supabase.co/functions/v1/duitku-callback',
      );

      if (invoice.statusCode != '00') {
        throw Exception(invoice.statusMessage);
      }

      // Update transaction_id di row payment yang SUDAH ada (tidak buat baru)
      await _supabase.from('payments').update(
          {'transaction_id': invoice.reference}).eq('booking_id', bookingId);

      if (!mounted) return;
      setState(() => _processingId = null);
      _openWebView(invoice.paymentUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal melanjutkan pembayaran: $e')),
      );
    }
  }

  // ──────────────────────────────────────────────
  //  BATALKAN — hapus booking + payment yang pending
  //  dan bebaskan slot mentor (jika sempat terkunci)
  // ──────────────────────────────────────────────
  Future<void> _cancelBooking(Map<String, dynamic> item) async {
    final booking = item['bookings'] as Map<String, dynamic>?;
    final bookingId = booking?['id'] as String?;
    if (bookingId == null) return;

    // Konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Booking?'),
        content: const Text(
            'Booking dan tagihan ini akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processingId = bookingId);

    try {
      // 1. Hapus row payment milik booking ini
      await _supabase.from('payments').delete().eq('booking_id', bookingId);

      // 2. Bebaskan slot mentor (kalau sempat ditandai booked)
      final b = await _supabase
          .from('bookings')
          .select('schedule_id')
          .eq('id', bookingId)
          .maybeSingle();

      if (b?['schedule_id'] != null) {
        await _supabase
            .from('mentor_schedules')
            .update({'is_booked': false}).eq('id', b!['schedule_id']);
      }

      // 3. Hapus booking
      await _supabase.from('bookings').delete().eq('id', bookingId);

      if (!mounted) return;
      await _loadTransactions();
      setState(() => _processingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking dibatalkan')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan: $e')),
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

              // ── List transaksi dikelompokkan per status ──
              ..._buildGroupedTransactions(),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Kelompokkan transaksi per status pembayaran
  //  Urutan: paid → pending → failed
  // ──────────────────────────────────────────────
  List<Widget> _buildGroupedTransactions() {
    if (_transactions.isEmpty) return [];

    // Pisahkan per status
    final paid =
        _transactions.where((t) => t['payment_status'] == 'paid').toList();
    final pending =
        _transactions.where((t) => t['payment_status'] == 'pending').toList();
    final failed = _transactions
        .where((t) =>
            t['payment_status'] != 'paid' && t['payment_status'] != 'pending')
        .toList();

    final widgets = <Widget>[];

    void addSection(
        String title, Color color, List<Map<String, dynamic>> items) {
      if (items.isEmpty) return;
      widgets.add(_sectionHeader(title, color, items.length));
      widgets.addAll(items.map(_transactionCard));
      widgets.add(const SizedBox(height: 8));
    }

    addSection('Sudah Dibayar', const Color(0xFF27AE60), paid);
    addSection('Menunggu Pembayaran', const Color(0xFFF39C12), pending);
    addSection('Gagal / Dibatalkan', const Color(0xFFE74C3C), failed);

    return widgets;
  }

  // Judul section per status
  Widget _sectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Kartu satu transaksi (dipindah dari .map() agar bisa dipakai grup)
  Widget _transactionCard(Map<String, dynamic> item) {
    final booking = item['bookings'] as Map<String, dynamic>?;
    final bio = item['_mentor'] as Map<String, dynamic>?;
    final schedule = booking?['mentor_schedules'] as Map<String, dynamic>?;

    final mentorName = bio?['nama_lengkap'] ?? 'Mentor';
    final tanggal =
        _formatDate(schedule?['available_date'] ?? item['created_at']);
    final amount = _formatRupiah(item['amount']);
    final status = item['payment_status'] as String?;
    final method = (item['payment_method'] as String? ?? '').toUpperCase();

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
      child: Column(
        children: [
          Row(
            children: [
              // Avatar / icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, color: Color(0xFF2E86C1)),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
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

          // ── Tombol aksi (hanya untuk status pending) ──
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            (_processingId == item['bookings']?['id'])
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    children: [
                      // Batalkan
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelBooking(item),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Batalkan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE74C3C),
                            side: const BorderSide(color: Color(0xFFE74C3C)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Bayar Sekarang
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _retryPayment(item),
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Bayar Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}
