import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../../controller/mentor/booking_detail_controller.dart';
import '../../../models/mentor/booking_detail_model.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final ScheduleBookingDetailController _controller =
      ScheduleBookingDetailController();

  Color _primaryColor = const Color(0xFFCDB4DB);
  String? _bookingId;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bookingId == null) {
      final args = (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          {};
      _bookingId = args['bookingId'] as String?;
      if (args['color'] is Color) _primaryColor = args['color'] as Color;
      _load();
    }
  }

  Future<void> _load() async {
    if (_bookingId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    await _controller.fetchDetail(_bookingId!);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Request Detail",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_controller.detail == null
              ? _buildError()
              : _buildContent(_controller.detail!)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _controller.errorMessage ?? 'Detail tidak ditemukan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScheduleBookingDetailModel d) {
    final status = d.bookingStatus.toLowerCase();
    final isPaid = status == 'paid'; // menunggu konfirmasi mentor
    final isRejected = status == 'rejected';
    final isAccepted = status == 'confirmed';

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- SECTION 1: HEADER PROFIL ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image: (d.clientPhotoUrl != null &&
                            d.clientPhotoUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(d.clientPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (d.clientPhotoUrl == null || d.clientPhotoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(
                  d.clientName,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (d.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d.categoryName!,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    if (!isPaid) ...[
                      const SizedBox(width: 8),
                      _statusChip(status),
                    ],
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ALASAN REJECT (jika rejected) ---
                if (isRejected) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Rejection Reason",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          (d.notes == null || d.notes!.isEmpty)
                              ? "No specific reason provided."
                              : d.notes!,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // --- SESSION INFO ---
                const Text(
                  "Session Info",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildCompactInfo(
                        Icons.calendar_today_rounded,
                        "Date",
                        d.formattedDate,
                        _primaryColor,
                      ),
                      const Divider(height: 30),
                      _buildCompactInfo(
                        Icons.access_time_filled_rounded,
                        "Time & Duration",
                        "${d.sessionTimeRange} (${d.durationLabel})",
                        _primaryColor,
                      ),
                      const Divider(height: 30),
                      _buildCompactInfo(
                        Icons.location_on_rounded,
                        "Location",
                        d.sessionAddress,
                        _primaryColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- CLIENT MESSAGE ---
                const Text(
                  "Message from Client",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    (d.notes == null || d.notes!.isEmpty || isRejected)
                        ? "Tidak ada pesan dari client."
                        : "\"${d.notes!}\"",
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- ACTION BUTTONS ---
                // Tombol Accept/Reject HANYA saat status 'paid'
                if (isPaid)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isProcessing ? null : () => _showRejectDialog(d),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Reject Request",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isProcessing ? null : () => _handleAccept(d),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BACFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Accept Now",
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Back to List",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'CONFIRMED';
        break;
      case 'rejected':
        color = Colors.redAccent;
        label = 'REJECTED';
        break;
      case 'cancelled':
      case 'failed':
        color = Colors.redAccent;
        label = 'CANCELLED';
        break;
      case 'awaiting_verification':
        color = Colors.purple;
        label = 'AWAITING';
        break;
      case 'done':
      case 'completed':
        color = Colors.blue;
        label = 'DONE';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'PENDING';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompactInfo(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── REJECT dialog ──
  void _showRejectDialog(ScheduleBookingDetailModel d) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reason for Rejection",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please tell the client why you can't accept this booking.",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Color.fromARGB(255, 54, 52, 52),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "E.g. Schedule conflict, out of town...",
                hintStyle: const TextStyle(fontSize: 13),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Navigator.pop(dialogCtx);
              _handleReject(d, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── ACCEPT → confirmed ──
  Future<void> _handleAccept(ScheduleBookingDetailModel d) async {
    setState(() => _isProcessing = true);
    final err = await _controller.acceptBooking(d.bookingId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (err == null) {
      _showToastThenPop(
        success: true,
        title: "Booking Accepted",
        desc: "You have accepted ${d.clientName}'s request",
      );
    } else {
      _errorToast(err);
    }
  }

  // ── REJECT → rejected + alasan ──
  Future<void> _handleReject(
      ScheduleBookingDetailModel d, String reason) async {
    setState(() => _isProcessing = true);
    final err = await _controller.rejectBooking(d.bookingId, reason: reason);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (err == null) {
      _showToastThenPop(
        success: false,
        title: "Booking Rejected",
        desc: "Request from ${d.clientName} has been declined",
      );
    } else {
      _errorToast(err);
    }
  }

  /// Tampilkan toast SETELAH frame selesai (hindari error "tree locked"),
  /// lalu pop halaman dengan hasil true SECARA TERPISAH (tidak di dalam
  /// onToastClosed, karena itu memicu rebuild saat overlay sedang menutup).
  void _showToastThenPop({
    required bool success,
    required String title,
    required String desc,
  }) {
    // 1. Tampilkan toast setelah frame selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final toast = success
          ? CherryToast.success(
              title: Text(title,
                  style: const TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
              description:
                  Text(desc, style: const TextStyle(fontFamily: 'Nunito')),
              animationType: AnimationType.fromTop,
              toastPosition: Position.top,
              autoDismiss: true,
            )
          : CherryToast.error(
              title: Text(title,
                  style: const TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
              description:
                  Text(desc, style: const TextStyle(fontFamily: 'Nunito')),
              animationType: AnimationType.fromTop,
              toastPosition: Position.top,
              autoDismiss: true,
            );
      toast.show(context);
    });

    // 2. Pop halaman SECARA TERPISAH setelah jeda singkat
    //    (memberi waktu toast tampil, lalu kembali ke list)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  void _errorToast(String msg) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CherryToast.error(
        title: const Text("Gagal",
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        description: Text(msg, style: const TextStyle(fontFamily: 'Nunito')),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
    });
  }
}
