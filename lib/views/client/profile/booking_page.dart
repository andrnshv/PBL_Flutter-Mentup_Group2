import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/client/mentor_profile_model.dart';
import '../../../controller/client/payment_controller.dart';

// ================================================================
//  BOOKING PAGE — MentUp
//  File: lib/views/client/profile/booking_page.dart
//
//  Tampilan 100% sama dengan aslinya (desain front end tidak diubah).
//  Perubahan hanya pada:
//  1. Parameter: MentorModel → MentorProfileModel (data dari Supabase)
//  2. Tombol "Submit Booking": sekarang simpan ke DB + buka Duitku
//  3. Status "webview" ditambahkan untuk tampilkan WebView Duitku
// ================================================================

class BookingPage extends StatefulWidget {
  final MentorProfileModel mentor;

  const BookingPage({
    super.key,
    required this.mentor,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primary = const Color(0xFF6C63FF);
  final _supabase = Supabase.instance.client;
  final _payCtrl = PaymentController();

  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();

  TimeOfDay? selectedTime;

  final TextEditingController noteController = TextEditingController();

  // status: "form" | "review" | "pending" | "webview"
  String status = "form";

  // WebView Duitku
  WebViewController? _webCtrl;
  bool _webLoading = false;

  // Booking & payment tracking
  String? _bookingId;
  String? _merchantOrderId;

  int get totalPrice => (widget.mentor.pricePerSession ?? 0);

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(status == "webview" ? "Pembayaran" : "Booking Mentor"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (status == "webview" && _webCtrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webCtrl!.reload(),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _payCtrl,
        builder: (_, __) => _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // ── WebView Duitku ─────────────────────
    if (status == "webview" && _webCtrl != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webCtrl!),
          if (_webLoading || _payCtrl.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    // ── Loading submit ─────────────────────
    if (_payCtrl.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Menyiapkan pembayaran...",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    switch (status) {
      case "review":
        return _buildReview();
      case "pending":
        return _buildWaiting();
      default:
        return _buildForm();
    }
  }

  /// ================= FORM =================

  Widget _buildForm() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= MENTOR =================

            _card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.1),
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
                subtitle: Text(widget.mentor.categoryName ?? 'Mentor'),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= CALENDAR =================

            const Text(
              "Select Mentoring Dates",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2030),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) {
                  return selectedDates.any(
                    (selectedDay) => isSameDay(selectedDay, day),
                  );
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    this.focusedDay = focusedDay;

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
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 15),

            if (selectedDates.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedDates.map((date) {
                  return Chip(
                    backgroundColor: primary.withValues(alpha: 0.1),
                    label: Text(
                      "${date.day}/${date.month}/${date.year}",
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        selectedDates.remove(date);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            /// ================= TIME =================

            _card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime == null
                      ? "Select Session Time"
                      : "Time: ${selectedTime!.format(context)}",
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            _input("Note (optional)", noteController),

            const SizedBox(height: 15),

            /// ================= PRICE =================

            _card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Price Detail",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${widget.mentor.pricePerSession ?? 0} x ${selectedDates.length} session",
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Price"),
                        Text(
                          "Rp $totalPrice",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= BUTTON =================

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (selectedDates.isNotEmpty && selectedTime != null) {
                  setState(() => status = "review");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please complete all data"),
                    ),
                  );
                }
              },
              child: const Text(
                "Review Booking",
                style: TextStyle(
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

  /// ================= REVIEW =================

  Widget _buildReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.9),
                  primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Booking Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Review your booking",
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primary.withValues(alpha: 0.1),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.mentor.categoryName ?? 'Mentor',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _summaryItem(
                    Icons.calendar_month,
                    "Selected Dates",
                    "${selectedDates.length} Dates",
                  ),
                  _summaryItem(
                    Icons.schedule,
                    "Time",
                    selectedTime != null ? selectedTime!.format(context) : "-",
                  ),
                  if (noteController.text.isNotEmpty)
                    _summaryItem(
                      Icons.note,
                      "Note",
                      noteController.text,
                    ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDates.map((date) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${date.day}/${date.month}/${date.year}",
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price Detail",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Rp ${widget.mentor.pricePerSession ?? 0} x ${selectedDates.length} session",
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Price",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rp $totalPrice",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: primary,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ PERUBAHAN: Submit Booking sekarang ke Supabase + Duitku
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(55),
            ),
            onPressed: _submitBooking,
            child: const Text(
              "Submit Booking",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SUBMIT BOOKING ke Supabase + Duitku =================

  Future<void> _submitBooking() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User belum login');

      // ── Ambil data klien ─────────────────────
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

      // ── Ambil jadwal pertama yang tersedia ───
      final availableSlot =
          widget.mentor.schedules.firstWhere((s) => !s.isBooked);

      // ── Simpan booking ke Supabase ───────────
      final bookingRes = await _supabase
          .from('bookings')
          .insert({
            'client_id': user.id,
            'mentor_id': widget.mentor.userId,
            'schedule_id': availableSlot.id,
            'booking_status': 'pending',
            'notes': noteController.text.trim(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      _bookingId = bookingRes['id'] as String;
      _merchantOrderId = _bookingId!.replaceAll('-', '').substring(0, 20);

      // ── Buat invoice ke Duitku ───────────────
      final paymentUrl = await _payCtrl.createPayment(
        bookingId: _bookingId!,
        amount: totalPrice,
        mentorName: widget.mentor.namaLengkap,
        clientEmail: clientEmail,
        clientName: clientName,
        clientPhone: clientPhone,
      );

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        _openWebView(paymentUrl);
      } else {
        throw Exception(_payCtrl.errorMessage ?? 'Gagal membuat invoice');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  /// ================= WEBVIEW DUITKU =================

  void _openWebView(String url) {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _webLoading = true),
        onPageFinished: (_) => setState(() => _webLoading = false),
        onNavigationRequest: (req) {
          // Tangkap deep link setelah klien selesai bayar
          if (req.url.startsWith('mentup://') ||
              req.url.contains('payment/return')) {
            _handleReturn();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));

    setState(() => status = "webview");
  }

  Future<void> _handleReturn() async {
    setState(() {
      _webCtrl = null;
      status = "form"; // reset sementara selama verify
    });

    if (_bookingId == null || _merchantOrderId == null) return;

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
        setState(() => status = "pending");
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran gagal. Silakan coba lagi.')),
        );
        setState(() => status = "review");
    }
  }

  /// ================= WAITING (tampilan asli dipertahankan) =================

  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.schedule,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            "Booking Submitted",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your booking request has been sent.\nPlease wait for mentor approval.",
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
              "Back to Home",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  /// ================= SUMMARY ITEM =================

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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// ================= DIALOG HASIL =================

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

  /// ================= UI HELPERS =================

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
}
