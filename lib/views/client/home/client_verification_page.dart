import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../../controller/client/verify_session_controller.dart';

// ================================================================
//  CLIENT VERIFICATION PAGE — MentUp
//  File: lib/views/client/home/client_verification_page.dart
//
//  Tampilan sama dengan desain awal. Data dari VerifySessionItem
//  (Supabase). Verify → booking jadi 'done'. Reject → kembali
//  'confirmed' supaya mentor upload bukti ulang.
//
//  Cara buka:
//    Navigator.push(context, MaterialPageRoute(
//      builder: (_) => ClientVerificationPage(session: item),
//    ));
// ================================================================

class ClientVerificationPage extends StatefulWidget {
  final VerifySessionItem session;

  const ClientVerificationPage({super.key, required this.session});

  @override
  State<ClientVerificationPage> createState() => _ClientVerificationPageState();
}

class _ClientVerificationPageState extends State<ClientVerificationPage> {
  final Color primaryColor = const Color(0xFF5B62CC);
  final _controller = VerifySessionController();

  bool isVerified = false;
  bool isRejected = false;
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;

    final String mentorName = s.mentorName;
    final String category = s.category;
    final String date = s.dateLabel;
    final String time = s.timeLabel;
    final String summary = (s.summary != null && s.summary!.isNotEmpty)
        ? s.summary!
        : "Mentor belum menambahkan ringkasan sesi.";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          "Verify Session",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage:
                            (s.fotoUrl != null && s.fotoUrl!.isNotEmpty)
                                ? NetworkImage(s.fotoUrl!)
                                : null,
                        child: (s.fotoUrl == null || s.fotoUrl!.isEmpty)
                            ? Text(
                                mentorName.isNotEmpty
                                    ? mentorName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mentorName,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$date • $time",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Session Proof",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bukti dari mentor (NetworkImage) ──
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFF4F6FA),
                      image: (s.proofUrl != null && s.proofUrl!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(s.proofUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (s.proofUrl == null || s.proofUrl!.isEmpty)
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_not_supported_outlined,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Belum ada bukti',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Session Summary",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      summary,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (!isVerified && !isRejected)
                    _processing
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _handleReject,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    side: const BorderSide(
                                        color: Colors.redAccent),
                                  ),
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleVerify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Verify",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                  // VERIFIED STATE
                  if (isVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "You have verified this mentoring session.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // REJECTED STATE
                  if (isRejected)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cancel_rounded, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "You rejected this session proof.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── VERIFY → update DB jadi 'done' ──
  Future<void> _handleVerify() async {
    setState(() => _processing = true);
    final ok = await _controller.verifySession(widget.session.bookingId);
    if (!mounted) return;
    setState(() {
      _processing = false;
      isVerified = ok;
    });

    if (ok) {
      CherryToast.success(
        title: const Text("Session Verified"),
        description: const Text("Thank you for confirming the session."),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
      // Kembali ke home setelah sebentar, beri tahu perlu refresh
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else {
      CherryToast.error(
        title: const Text("Gagal"),
        description: Text(_controller.errorMessage ?? "Coba lagi."),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
    }
  }

  // ── REJECT → kembalikan ke 'confirmed' ──
  Future<void> _handleReject() async {
    setState(() => _processing = true);
    final ok = await _controller.rejectSession(widget.session.bookingId);
    if (!mounted) return;
    setState(() {
      _processing = false;
      isRejected = ok;
    });

    if (ok) {
      CherryToast.error(
        title: const Text("Session Rejected"),
        description: const Text("Mentor will need to resubmit proof."),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else {
      CherryToast.error(
        title: const Text("Gagal"),
        description: Text(_controller.errorMessage ?? "Coba lagi."),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
      ).show(context);
    }
  }
}
