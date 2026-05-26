import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../controller/client/booking_controller.dart';
import '../../../controller/client/payment_controller.dart';
import '../../../models/client/mentor_profile_model.dart';

// ================================================================
//  BOOKING PAGE — MentUp
//  File: lib/views/client/profile/booking_page.dart
//
//  Menerima MentorProfileModel langsung dari MentorProfilePage.
//  Alur: pilih jadwal → isi catatan → review → submit booking ke
//        Supabase → buat invoice Duitku → buka WebView → verifikasi
//        → dialog hasil.
// ================================================================

class BookingPage extends StatefulWidget {
  final MentorProfileModel mentor;

  const BookingPage({super.key, required this.mentor});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // ── warna tema ──────────────────────────────
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _bg = Color(0xFFF4F6FA);

  // ── controller ─────────────────────────────
  final _bookingCtrl = BookingController();
  final _payCtrl = PaymentController();
  final _noteCtrl = TextEditingController();
  final _supabase = Supabase.instance.client;

  // ── state form ──────────────────────────────
  MentorScheduleItem? _selectedSlot; // slot jadwal yang dipilih

  // ── status halaman ──────────────────────────
  // 'form' | 'review' | 'loading' | 'webview'
  String _status = 'form';

  // ── WebView ─────────────────────────────────
  WebViewController? _webCtrl;
  bool _webLoading = false;

  // ── data payment (disimpan untuk verify) ────
  String? _bookingId;
  String? _merchantOrderId;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── harga total ─────────────────────────────
  int get _totalPrice => widget.mentor.pricePerSession ?? 0;

  // ──────────────────────────────────────────
  //  Slot tersedia (filter yang belum dibooked)
  // ──────────────────────────────────────────
  List<MentorScheduleItem> get _availableSlots =>
      widget.mentor.schedules.where((s) => !s.isBooked).toList();

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Booking Mentor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_status == 'webview' && _webCtrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webCtrl!.reload(),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _payCtrl,
        builder: (_, __) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // ── WebView aktif ──────────────────────
    if (_status == 'webview' && _webCtrl != null) {
      return Stack(children: [
        WebViewWidget(controller: _webCtrl!),
        if (_webLoading || _payCtrl.isLoading)
          const Center(child: CircularProgressIndicator()),
      ]);
    }

    // ── Loading ────────────────────────────
    if (_status == 'loading') {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text('Menyiapkan pembayaran...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // ── Review ─────────────────────────────
    if (_status == 'review') return _buildReview();

    // ── Form (default) ─────────────────────
    return _buildForm();
  }

  // ══════════════════════════════════════════
  //  FORM — pilih jadwal & isi catatan
  // ══════════════════════════════════════════
  Widget _buildForm() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card info mentor ──────────
            _card(
                child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: _primary.withValues(alpha: 0.1),
                backgroundImage: widget.mentor.fotoUrl != null
                    ? NetworkImage(widget.mentor.fotoUrl!)
                    : null,
                child: widget.mentor.fotoUrl == null
                    ? Text(
                        widget.mentor.namaLengkap.isNotEmpty
                            ? widget.mentor.namaLengkap[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: _primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(widget.mentor.namaLengkap,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                widget.mentor.categoryName ?? 'Mentor',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: widget.mentor.pricePerSession != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${_formatNumber(widget.mentor.pricePerSession!)}',
                          style: const TextStyle(
                              color: _primary, fontWeight: FontWeight.bold),
                        ),
                        const Text('per sesi',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  : null,
            )),

            const SizedBox(height: 20),

            // ── Pilih Jadwal ──────────────
            const Text('Pilih Jadwal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            if (_availableSlots.isEmpty)
              _card(
                  child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, color: Colors.grey, size: 36),
                      SizedBox(height: 8),
                      Text('Tidak ada jadwal tersedia',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ))
            else
              _card(
                  child: Column(
                children: _availableSlots.asMap().entries.map((entry) {
                  final i = entry.key;
                  final slot = entry.value;
                  final isSelected = _selectedSlot?.id == slot.id;

                  // Format waktu: "08:00" dari "08:00:00"
                  final start = slot.startTime.length >= 5
                      ? slot.startTime.substring(0, 5)
                      : slot.startTime;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _selectedSlot = slot),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? _primary : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _primary
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color:
                                      isSelected ? Colors.white : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(slot.availableDate),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? _primary
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Mulai $start WIB',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: _primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                      if (i < _availableSlots.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              )),

            const SizedBox(height: 20),

            // ── Catatan ───────────────────
            const Text('Catatan (opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            _card(
                child: TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Topik yang ingin dipelajari, pertanyaan, dll...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            )),

            const SizedBox(height: 20),

            // ── Ringkasan harga ───────────
            if (widget.mentor.pricePerSession != null)
              _card(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rincian Harga',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Harga sesi'),
                        Text(
                          'Rp ${_formatNumber(widget.mentor.pricePerSession!)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Rp ${_formatNumber(_totalPrice)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _primary),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

            const SizedBox(height: 24),

            // ── Tombol lanjut ─────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _availableSlots.isEmpty
                  ? null
                  : () {
                      if (_selectedSlot == null) {
                        _snack('Pilih jadwal terlebih dahulu');
                        return;
                      }
                      setState(() => _status = 'review');
                    },
              child: const Text(
                'Review Booking',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  //  REVIEW — konfirmasi sebelum bayar
  // ══════════════════════════════════════════
  Widget _buildReview() {
    final slot = _selectedSlot!;
    final start = slot.startTime.length >= 5
        ? slot.startTime.substring(0, 5)
        : slot.startTime;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header banner ─────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _primary.withValues(alpha: 0.9),
                _primary.withValues(alpha: 0.65),
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Booking',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 4),
                Text('Periksa detail sebelum bayar',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Detail card ───────────────
          _card(
              child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mentor row
                Row(children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _primary.withValues(alpha: 0.1),
                    backgroundImage: widget.mentor.fotoUrl != null
                        ? NetworkImage(widget.mentor.fotoUrl!)
                        : null,
                    child: widget.mentor.fotoUrl == null
                        ? Text(
                            widget.mentor.namaLengkap.isNotEmpty
                                ? widget.mentor.namaLengkap[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.mentor.namaLengkap,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.mentor.categoryName ?? 'Mentor',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ]),

                const SizedBox(height: 16),
                const Divider(),

                _reviewRow(Icons.calendar_month, 'Tanggal',
                    _formatDate(slot.availableDate)),
                _reviewRow(Icons.schedule, 'Waktu Mulai', '$start WIB'),
                if (_noteCtrl.text.trim().isNotEmpty)
                  _reviewRow(
                      Icons.sticky_note_2, 'Catatan', _noteCtrl.text.trim()),

                const SizedBox(height: 16),

                // Harga
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Harga per sesi'),
                          Text(
                            'Rp ${_formatNumber(widget.mentor.pricePerSession ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bayar',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Rp ${_formatNumber(_totalPrice)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 16),

          // ── Tombol kembali ────────────
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => setState(() => _status = 'form'),
            child: const Text('Kembali', style: TextStyle(color: _primary)),
          ),

          const SizedBox(height: 10),

          // ── Tombol bayar ──────────────
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size.fromHeight(55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: _submitAndPay,
            child: const Text(
              'Bayar Sekarang',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  AKSI: Submit booking → Duitku → WebView
  // ══════════════════════════════════════════
  Future<void> _submitAndPay() async {
    setState(() => _status = 'loading');

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User belum login');

      // ── 1. Ambil data klien ─────────────
      final userRow = await _supabase
          .from('appuser')
          .select('nama_lengkap, email')
          .eq('id', user.id)
          .single();

      final bioRow = await _supabase
          .from('bio_profil')
          .select('nomor_hp')
          .eq('user_id', user.id)
          .maybeSingle();

      final clientName = userRow['nama_lengkap'] as String? ?? 'Klien';
      final clientEmail = userRow['email'] as String? ?? '';
      final clientPhone = bioRow?['nomor_hp'] as String? ?? '08100000000';

      // ── 2. Buat booking di Supabase ─────
      _bookingId = await _bookingCtrl.createBooking(
        mentorId: widget.mentor.userId,
        scheduleId: _selectedSlot!.id,
        notes: _noteCtrl.text.trim(),
      );

      if (_bookingId == null) {
        throw Exception('Gagal membuat booking. Silakan coba lagi.');
      }

      // merchantOrderId: UUID tanpa tanda hubung, max 20 karakter
      _merchantOrderId = _bookingId!.replaceAll('-', '').substring(0, 20);

      // ── 3. Buat invoice Duitku ──────────
      final paymentUrl = await _payCtrl.createPayment(
        bookingId: _bookingId!,
        amount: _totalPrice,
        mentorName: widget.mentor.namaLengkap,
        clientEmail: clientEmail,
        clientName: clientName,
        clientPhone: clientPhone,
      );

      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw Exception(
            _payCtrl.errorMessage ?? 'Gagal membuat invoice pembayaran.');
      }

      // ── 4. Buka WebView ─────────────────
      _openWebView(paymentUrl);
    } catch (e) {
      setState(() => _status = 'review');
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ══════════════════════════════════════════
  //  WebView
  // ══════════════════════════════════════════
  void _openWebView(String url) {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _webLoading = true),
        onPageFinished: (_) => setState(() => _webLoading = false),
        onNavigationRequest: (req) {
          // Tangkap deep link mentup:// atau returnUrl
          if (req.url.startsWith('mentup://') ||
              req.url.contains('payment/return')) {
            _handleReturn();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));

    setState(() => _status = 'webview');
  }

  // ══════════════════════════════════════════
  //  Handle kembali dari Duitku
  // ══════════════════════════════════════════
  Future<void> _handleReturn() async {
    setState(() {
      _webCtrl = null;
      _status = 'loading';
    });

    final result = await _payCtrl.verifyPayment(
      bookingId: _bookingId!,
      merchantOrderId: _merchantOrderId!,
    );

    if (!mounted) return;

    switch (result) {
      case 'paid':
        _showResultDialog(
          icon: Icons.check_circle_outline,
          color: Colors.green,
          title: 'Pembayaran Berhasil!',
          message: 'Booking kamu sudah dikonfirmasi.\nSelamat belajar! 🎉',
          onClose: () => Navigator.popUntil(context, (r) => r.isFirst),
        );
        break;

      case 'pending':
        _showResultDialog(
          icon: Icons.hourglass_top_rounded,
          color: Colors.orange,
          title: 'Menunggu Pembayaran',
          message:
              'Invoice masih aktif.\nSelesaikan pembayaran sebelum expired.',
          onClose: () => Navigator.pop(context),
        );
        break;

      default:
        setState(() => _status = 'review');
        _snack('Pembayaran gagal atau dibatalkan.');
    }
  }

  // ══════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // Format angka ribuan: 50000 → "50.000"
  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  // Format tanggal: "2025-06-01" → "Minggu, 1 Jun 2025"
  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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
        'Des'
      ];
      final day = days[dt.weekday - 1];
      return '$day, ${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 17, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey))),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onClose,
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}
