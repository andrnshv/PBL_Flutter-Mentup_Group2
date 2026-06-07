import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/client/mentor_profile_controller.dart';
import '../../../models/client/mentor_profile_model.dart';
import 'booking_page.dart';

class MentorProfilePage extends StatefulWidget {
  final String mentorId;
  const MentorProfilePage({super.key, required this.mentorId});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  final MentorProfileController _controller = MentorProfileController();

  static const Color _primary = Color(0xFF6C63FF);
  static const Color _bgColor = Color(0xFFF4F6FA);

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  bool _isLoading      = true;
  bool _showAllReviews = false; // toggle see all

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _controller.fetchProfile(widget.mentorId);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final url   = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_controller.errorMessage != null || _controller.profileData == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage ?? 'Data tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadProfile();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final mentor      = _controller.profileData!;
    final isAvailable = mentor.schedules.any((s) => !s.isBooked);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, mentor, isAvailable),
            const SizedBox(height: 65),

            // Nama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                mentor.namaLengkap,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),

            if (mentor.categoryName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mentor.categoryName!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: _primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 4),

            if (mentor.universityName != null)
              Text(mentor.universityName!,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),

            if (mentor.alamat != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      mentor.alamat!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Rating + availability badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mentor.avgRating != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(mentor.avgRating!.toStringAsFixed(1)),
                  if (mentor.totalReviews != null)
                    Text(' (${mentor.totalReviews})',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(width: 10),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAvailable ? Colors.green : Colors.grey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: mentor.nomorHp != null
                          ? () => _openWhatsApp(mentor.nomorHp!)
                          : null,
                      icon: const Icon(Icons.chat),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(
                                    mentorId: widget.mentorId,
                                    mentor: mentor,
                                  ),
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                            ? _primary
                            : const Color(0xFFE0E0E0),
                        foregroundColor: isAvailable
                            ? Colors.white
                            : Colors.grey.shade600,
                        disabledBackgroundColor:
                            const Color(0xFFE0E0E0),
                        disabledForegroundColor: Colors.grey.shade600,
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isAvailable
                              ? Icons.calendar_month
                              : Icons.block, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isAvailable ? 'Book Session' : 'Not Available',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Quick info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem('Price',
                      mentor.pricePerSession != null
                          ? _currency.format(mentor.pricePerSession)
                          : '-'),
                  _infoItem('Reviews',
                      mentor.totalReviews?.toString() ?? '-'),
                  _infoItem('Rating',
                      mentor.avgRating != null
                          ? mentor.avgRating!.toStringAsFixed(1)
                          : '-'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About
            _section(
              title: 'About',
              content: (mentor.bio != null && mentor.bio!.isNotEmpty)
                  ? mentor.bio!
                  : 'Mentor profesional di bidang '
                    '${mentor.categoryName ?? "mentoring"}. '
                    'Siap membantu kamu berkembang 🚀',
            ),

            // ── REVIEWS ─────────────────────────────────────
            _buildReviewsSection(mentor),

            // Available Schedules
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Schedules',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Builder(builder: (_) {
                      final available = mentor.schedules
                          .where((s) => !s.isBooked)
                          .toList();
                      if (available.isEmpty) {
                        return const Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_busy,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('No available schedule',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: available.map((sched) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    color: _primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${sched.availableDate} • ${sched.startTime}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.green.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Text('Available',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REVIEWS SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildReviewsSection(MentorProfileModel mentor) {
    final reviews      = mentor.reviews;
    // Tampilkan 3 dulu, sisanya setelah "See All" ditekan
    final displayLimit = _showAllReviews ? reviews.length : 3;
    final displayed    = reviews.take(displayLimit).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Reviews',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    if (reviews.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${reviews.length}',
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                // See All / Show Less
                if (reviews.length > 3)
                  TextButton(
                    onPressed: () =>
                        setState(() => _showAllReviews = !_showAllReviews),
                    child: Text(
                      _showAllReviews ? 'Show Less' : 'See All',
                      style: const TextStyle(color: _primary),
                    ),
                  ),
              ],
            ),

            // ── Rating summary ───────────────────────────
            if (mentor.avgRating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    mentor.avgRating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _starRow(mentor.avgRating!),
                      Text(
                        'dari ${mentor.totalReviews ?? 0} ulasan',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
            ],

            // ── Empty state ──────────────────────────────
            if (reviews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada ulasan',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

            // ── Review list ──────────────────────────────
            ...displayed.map((review) => _buildReviewCard(review)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(MentorReviewItem review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _primary.withOpacity(0.1),
            backgroundImage: review.clientFotoUrl != null
                ? NetworkImage(review.clientFotoUrl!)
                : null,
            child: review.clientFotoUrl == null
                ? Text(
                    review.clientName.isNotEmpty
                        ? review.clientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: _primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.clientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      review.dateLabel,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Bintang
                _starRow(review.rating.toDouble(), size: 14),
                const SizedBox(height: 6),

                // Teks review
                if (review.reviewText != null &&
                    review.reviewText!.isNotEmpty)
                  Text(
                    review.reviewText!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  )
                else
                  Text('Tidak ada komentar.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Star row ─────────────────────────────────────────
  Widget _starRow(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, color: Colors.amber, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded,
              color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border_rounded,
              color: Colors.grey[300], size: size);
        }
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, MentorProfileModel mentor, bool isAvailable) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primary.withOpacity(0.7)],
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: _primary.withOpacity(0.15),
                    backgroundImage: mentor.fotoUrl != null
                        ? NetworkImage(mentor.fotoUrl!)
                        : null,
                    child: mentor.fotoUrl == null
                        ? Text(
                            mentor.namaLengkap.isNotEmpty
                                ? mentor.namaLengkap[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: _primary,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _section({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}