import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../controller/client/booking_controller.dart';
import '../../../models/client/mentor_profile_model.dart';
import '../map/map_picker_page.dart';

// ================================================================
//  BOOKING PAGE (VIEW) — MentUp
//  File: lib/views/client/profile/booking_page.dart
//
//  View murni: hanya UI + state tampilan. Semua logika booking &
//  pembayaran ada di BookingFormController (MVC).
// ================================================================

class BookingPage extends StatefulWidget {
  final String mentorId; // = mentor.userId (appuser id)
  final MentorProfileModel mentor;
  final bool isReschedule;
  final Map<String, dynamic>? oldData;

  const BookingPage({
    super.key,
    required this.mentorId,
    required this.mentor,
    this.isReschedule = false,
    this.oldData,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingFormController _controller = BookingFormController();
  final Color primary = const Color(0xFF6C63FF);

  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();
  LatLng? selectedLocation;
  TimeOfDay? selectedTime; // jam mulai
  TimeOfDay? selectedEndTime; // jam selesai

  final TextEditingController noteController = TextEditingController();

  /// _step: 'form' | 'review' | 'webview' | 'pending'
  String _step = 'form';
  bool _isSubmitting = false;

  // ── WebView Duitku ──
  WebViewController? _webCtrl;
  bool _webLoading = false;

  /// Durasi 1 sesi dalam jam (dari selisih jam mulai & selesai).
  /// Mengembalikan 0 jika jam belum dipilih.
  double get sessionHours {
    if (selectedTime == null || selectedEndTime == null) return 0;
    final startMin = selectedTime!.hour * 60 + selectedTime!.minute;
    final endMin = selectedEndTime!.hour * 60 + selectedEndTime!.minute;
    final diff = endMin - startMin;
    if (diff <= 0) return 0;
    return diff / 60.0;
  }

  /// Harga per jam (field pricePerSession di-treat sebagai harga per jam).
  int get pricePerHour => widget.mentor.pricePerSession ?? 0;

  /// Harga untuk 1 hari/sesi = harga per jam × jumlah jam.
  int get pricePerBooking => (pricePerHour * sessionHours).round();

  /// Total = harga per sesi × jumlah hari yang dipesan.
  int get totalPrice => pricePerBooking * selectedDates.length;

  /// Format jam: 4.0 → "4", 1.5 → "1.5"
  String get sessionHoursLabel {
    if (sessionHours == sessionHours.roundToDouble()) {
      return sessionHours.toInt().toString();
    }
    return sessionHours.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadSlots();

    if (widget.isReschedule && widget.oldData != null) {
      final data = widget.oldData!;
      selectedDates = List<DateTime>.from(data['dates'] ?? []);
      noteController.text = data['note'] ?? '';
    }
  }

  Future<void> _loadSlots() async {
    await _controller.fetchAvailableSlots(widget.mentorId);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          widget.isReschedule
              ? 'Reschedule Session'
              : (_step == 'review'
                  ? 'Review Booking'
                  : (_step == 'webview' ? 'Pembayaran' : 'Booking Mentor')),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: _step == 'review'
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => setState(() => _step = 'form'),
              )
            : null,
        actions: [
          if (_step == 'webview' && _webCtrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webCtrl!.reload(),
            ),
        ],
      ),
      body: () {
        switch (_step) {
          case 'review':
            return _buildReview();
          case 'pending':
            return _buildWaiting();
          case 'webview':
            return _buildWebView();
          default:
            return _buildForm();
        }
      }(),
    );
  }

  // ════════════════════════════════════════════════════════
  // FORM
  // ════════════════════════════════════════════════════════
  Widget _buildForm() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mentor card ───────────────────────────
            _card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.15),
                  backgroundImage: widget.mentor.fotoUrl != null
                      ? NetworkImage(widget.mentor.fotoUrl!)
                      : null,
                  child: widget.mentor.fotoUrl == null
                      ? Text(
                          widget.mentor.namaLengkap.isNotEmpty
                              ? widget.mentor.namaLengkap[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: primary, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(
                  widget.mentor.namaLengkap,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: widget.mentor.categoryName != null
                    ? Text(widget.mentor.categoryName!)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // ── Calendar ─────────────────────────────
            const Text(
              'Select Mentoring Dates',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _controller.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime(2030),
                      focusedDay: focusedDay,

                      // Hanya tanggal yang punya slot bisa dipilih
                      enabledDayPredicate: (day) => _controller.availableDays
                          .any((d) => isSameDay(d, day)),

                      selectedDayPredicate: (day) {
                        return selectedDates.any(
                          (selectedDay) => isSameDay(selectedDay, day),
                        );
                      },

                      onDaySelected: (selectedDay, focused) {
                        setState(() {
                          focusedDay = focused;
                          final exists = selectedDates.any(
                            (d) => isSameDay(d, selectedDay),
                          );
                          if (exists) {
                            selectedDates.removeWhere(
                              (d) => isSameDay(d, selectedDay),
                            );
                          } else {
                            selectedDates.add(selectedDay);
                          }
                        });
                      },

                      calendarBuilders: CalendarBuilders(
                        // Dot hijau untuk tanggal yang ada slot
                        markerBuilder: (context, day, _) {
                          if (_controller.availableDays
                              .any((d) => isSameDay(d, day))) {
                            return Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),

                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: primary.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        disabledTextStyle:
                            const TextStyle(color: Color(0xFFDADADA)),
                      ),

                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),

            const SizedBox(height: 15),

            // ── Chip list tanggal terpilih ───────────
            if (selectedDates.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedDates.map((date) {
                  return Chip(
                    backgroundColor: primary.withOpacity(0.1),
                    label: Text('${date.day}/${date.month}/${date.year}'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() => selectedDates.remove(date));
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // ── Time picker ──────────────────────────
            _card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime == null
                      ? 'Select Session Time'
                      : (selectedEndTime == null
                          ? 'Time: ${selectedTime!.format(context)}'
                          : 'Time: ${selectedTime!.format(context)} - ${selectedEndTime!.format(context)}'),
                ),
                onTap: () async {
                  // 1. Pilih jam mulai
                  final start = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                    helpText: 'Pilih Jam Mulai',
                  );
                  if (start == null) return;

                  // 2. Pilih jam selesai
                  final end = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime ??
                        TimeOfDay(
                            hour: (start.hour + 1) % 24, minute: start.minute),
                    helpText: 'Pilih Jam Selesai',
                  );
                  if (end == null) return;

                  // Validasi: jam selesai harus setelah jam mulai
                  final startMin = start.hour * 60 + start.minute;
                  final endMin = end.hour * 60 + end.minute;
                  if (endMin <= startMin) {
                    _snack('Jam selesai harus setelah jam mulai',
                        Colors.redAccent);
                    return;
                  }

                  setState(() {
                    selectedTime = start;
                    selectedEndTime = end;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Location picker ──────────────────────
            _card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  selectedLocation == null
                      ? 'Select Location'
                      : 'Location selected ✓',
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapPickerPage(),
                    ),
                  );
                  if (result != null) {
                    setState(() => selectedLocation = result);
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            // ── Note ─────────────────────────────────
            _input('Note (optional)', noteController),

            const SizedBox(height: 15),

            // ── Price ─────────────────────────────────
            _card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Detail',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mentor.pricePerSession != null
                          ? 'Rp ${_formatPrice(pricePerHour)}/jam × $sessionHoursLabel jam × ${selectedDates.length} hari'
                          : 'Harga belum ditentukan',
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Price'),
                        Text(
                          'Rp ${_formatPrice(totalPrice)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ── Tombol Review ─────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (selectedDates.isNotEmpty &&
                    selectedTime != null &&
                    selectedEndTime != null &&
                    selectedLocation != null) {
                  setState(() => _step = 'review');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all data'),
                    ),
                  );
                }
              },
              child: Text(
                widget.isReschedule ? 'Update Schedule' : 'Review Booking',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // REVIEW
  // ════════════════════════════════════════════════════════
  Widget _buildReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.9), primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Review your booking',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mentor
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primary.withOpacity(0.1),
                        backgroundImage: widget.mentor.fotoUrl != null
                            ? NetworkImage(widget.mentor.fotoUrl!)
                            : null,
                        child: widget.mentor.fotoUrl == null
                            ? Icon(Icons.person, color: primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mentor.namaLengkap,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (widget.mentor.categoryName != null)
                            Text(
                              widget.mentor.categoryName!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  _summaryItem(
                    Icons.calendar_month,
                    'Selected Dates',
                    '${selectedDates.length} Dates',
                  ),
                  _summaryItem(
                    Icons.schedule,
                    'Time',
                    (selectedTime != null && selectedEndTime != null)
                        ? '${selectedTime!.format(context)} - ${selectedEndTime!.format(context)}'
                        : (selectedTime != null
                            ? selectedTime!.format(context)
                            : '-'),
                  ),
                  _summaryItem(
                    Icons.location_on,
                    'Location',
                    selectedLocation == null ? '-' : 'Selected ✓',
                  ),
                  if (noteController.text.isNotEmpty)
                    _summaryItem(
                      Icons.note,
                      'Note',
                      noteController.text,
                    ),

                  const SizedBox(height: 15),

                  // Wrap chip tanggal
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDates.map((date) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: TextStyle(
                              color: primary, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price Detail',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.mentor.pricePerSession != null
                              ? 'Rp ${_formatPrice(pricePerHour)}/jam × $sessionHoursLabel jam × ${selectedDates.length} hari'
                              : 'Harga belum ditentukan',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rp ${_formatPrice(totalPrice)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(55),
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Submit Booking',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // WEBVIEW DUITKU
  // ════════════════════════════════════════════════════════
  Widget _buildWebView() {
    return Stack(
      children: [
        if (_webCtrl != null) WebViewWidget(controller: _webCtrl!),
        if (_webLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // WAITING / SUCCESS
  // ════════════════════════════════════════════════════════
  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Booking Submitted',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your booking request has been sent. Please wait for mentor approval.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Home',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SUBMIT HANDLER — semua logic di controller
  // ════════════════════════════════════════════════════════
  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final locationText = selectedLocation != null
        ? '${selectedLocation!.latitude},${selectedLocation!.longitude}'
        : '';

    // 1. Simpan booking ke Supabase (via controller)
    final result = await _controller.submitMultipleBookings(
      mentorId: widget.mentorId,
      selectedDates: selectedDates,
      selectedTime: selectedTime!,
      locationText: locationText,
      notes: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );

    if (!mounted) return;

    // Gagal semua
    if (result.isFullFail) {
      setState(() => _isSubmitting = false);
      _snack(
          result.errorMessage ?? 'Booking gagal. Coba lagi.', Colors.redAccent);
      return;
    }

    // Partial → kasih tahu
    if (result.isPartialSuccess) {
      _snack(
        '${result.successIds.length} booking berhasil, '
        '${result.failedDates.length} tanggal gagal. Lanjut bayar.',
        Colors.orange,
      );
    }

    // 2. Buat invoice Duitku (via controller)
    final payment = await _controller.createPaymentForBookings(
      bookingIds: result.successIds,
      amountPerBooking: pricePerBooking,
      mentorName: widget.mentor.namaLengkap,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (payment.isSuccess) {
      _openWebView(payment.paymentUrl!);
    } else {
      _snack(payment.errorMessage ?? 'Gagal membuat invoice Duitku',
          Colors.redAccent);
    }
  }

  // ════════════════════════════════════════════════════════
  // WEBVIEW + VERIFY
  // ════════════════════════════════════════════════════════
  void _openWebView(String url) {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _webLoading = true),
        onPageFinished: (_) => setState(() => _webLoading = false),
        onNavigationRequest: (req) {
          if (req.url.startsWith('mentup://') ||
              req.url.contains('payment/return')) {
            _handleReturn();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));

    setState(() => _step = 'webview');
  }

  Future<void> _handleReturn() async {
    setState(() {
      _webCtrl = null;
      _webLoading = true;
    });

    // Verifikasi via controller
    final paymentStatus = await _controller.verifyCurrentPayment();

    if (!mounted) return;
    setState(() => _webLoading = false);

    switch (paymentStatus) {
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
        setState(() => _step = 'pending');
        break;
      default:
        setState(() => _step = 'review');
        _snack('Pembayaran gagal atau dibatalkan.', Colors.redAccent);
    }
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════
  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primary, foregroundColor: Colors.white),
              onPressed: onClose,
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _input(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
