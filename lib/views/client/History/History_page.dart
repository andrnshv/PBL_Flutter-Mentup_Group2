import 'package:flutter/material.dart';
import '../../../controller/client/history_controller.dart';
import '../profile/edit_security.dart';
import 'reschedule_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController _controller = HistoryController();

  int  selectedTab    = 0;
  int  selectedRating = 5;
  bool _isLoading     = true;
  bool _submitting    = false;

  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchHistory();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleReschedule(HistoryItemModel data) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ReschedulePage(booking: data)),
    );
    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _load();
    }
  }

  Future<void> _handleCancel(HistoryItemModel data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Booking?'),
        content: const Text(
          'Booking akan dibatalkan. Kamu bisa mengajukan refund '
          'ke admin lewat Help Center.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final err = await _controller.cancelRejected(data.bookingId);
    if (!mounted) return;

    if (err == null) {
      setState(() => _isLoading = true);
      await _load();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Booking Dibatalkan'),
          content: const Text('Ajukan refund ke admin lewat Help Center.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditSecurityPage()),
                );
              },
              child: const Text('Ke Help Center'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: Colors.amber,
        );
      }),
    );
  }

  void _showReviewSheet(HistoryItemModel data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            _avatar(data, 35),
            const SizedBox(height: 12),
            Text(data.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(data.role,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 15),
            _buildStars(data.rating ?? 0),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                data.review ?? '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[800], fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showGiveReviewSheet(HistoryItemModel data) {
    reviewController.clear();
    selectedRating = 5;

    // Guard: jika bookingHistoryId null, tampilkan pesan
    if (data.bookingHistoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sesi belum memiliki riwayat. '
            'Pastikan sesi sudah diverifikasi selesai.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                _avatar(data, 35),
                const SizedBox(height: 12),
                Text(data.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("How was your mentoring session?",
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () =>
                          setModalState(() => selectedRating = index + 1),
                      icon: Icon(
                        index < selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reviewController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your review here...",
                    filled: true,
                    fillColor: const Color(0xFFF4F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            if (reviewController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please write your review first"),
                                ),
                              );
                              return;
                            }

                            setModalState(() => _submitting = true);

                            // ← pass bookingHistoryId dari field model
                            final ok = await _controller.submitReview(
                              mentorId:         data.mentorId,
                              bookingHistoryId: data.bookingHistoryId,
                              rating:           selectedRating,
                              reviewText:       reviewController.text.trim(),
                            );

                            setModalState(() => _submitting = false);
                            if (!mounted) return;
                            Navigator.pop(context);

                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Review submitted successfully!"),
                                ),
                              );
                              setState(() => _isLoading = true);
                              _load();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      _controller.errorMessage ??
                                          "Gagal mengirim review"),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Submit Review"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = selectedTab == 0
        ? _controller.doneList
        : _controller.cancelledList;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8E7CFF)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Session History",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _tabItem("Done", 0),
                      const SizedBox(width: 10),
                      _tabItem("Cancelled", 1),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (currentList.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            setState(() => _isLoading = true);
                            await _load();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: currentList.length,
                            itemBuilder: (_, i) =>
                                _historyCard(currentList[i]),
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            selectedTab == 0
                ? "Belum ada sesi yang selesai"
                : "Belum ada sesi yang dibatalkan",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.purple : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(HistoryItemModel data, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
      backgroundImage:
          (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
              ? NetworkImage(data.fotoUrl!)
              : null,
      child: (data.fotoUrl == null || data.fotoUrl!.isEmpty)
          ? Text(
              data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _historyCard(HistoryItemModel data) {
    final isDone     = data.status == "Done";
    final isReviewed = data.isReviewed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(data, 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(data.role,
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 5),
                    Text(data.dateLabel,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.statusLabel,
                  style: TextStyle(
                    color: isDone ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          // ── REVIEW SECTION ────────────────────────────────
          if (isDone) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: isReviewed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.reviews_rounded,
                                color: Colors.purple, size: 20),
                            SizedBox(width: 8),
                            Text("Your Review",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStars(data.rating ?? 0),
                        const SizedBox(height: 12),
                        Text(data.review ?? '',
                            style: TextStyle(
                                color: Colors.grey[700], height: 1.5)),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showReviewSheet(data),
                            child: const Text("See Detail"),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rate_review_rounded,
                                color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You haven't reviewed this mentoring session yet.",
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showGiveReviewSheet(data),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("Give Review"),
                          ),
                        ),
                      ],
                    ),
            ),
          ],

          // ── REJECTED: alasan + Reschedule/Cancel ─────────
          if (!isDone && data.isRejected) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.04),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: Colors.red.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.cancelReason != null &&
                      data.cancelReason!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Alasan penolakan:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.redAccent)),
                              const SizedBox(height: 4),
                              Text(data.cancelReason!,
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 1.4,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleCancel(data),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(
                                color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleReschedule(data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                          child: const Text('Reschedule',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}