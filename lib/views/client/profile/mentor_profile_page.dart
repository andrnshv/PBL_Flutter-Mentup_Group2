import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/client/mentor_profile_controller.dart';
import '../../../models/client/mentor_profile_model.dart';
// ✅ TAMBAHAN: import BookingPage
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
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;

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
    final url = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Done':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
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

    final mentor = _controller.profileData!;
    final bool isAvailable = mentor.schedules.any((s) => !s.isBooked);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────
            _buildHeader(context, mentor, isAvailable),

            const SizedBox(height: 65),

            // ── NAMA & BADGE ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                mentor.namaLengkap,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 6),

            if (mentor.categoryName != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mentor.categoryName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 4),

            if (mentor.universityName != null)
              Text(
                mentor.universityName!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),

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
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // ── RATING + STATUS ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mentor.avgRating != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(mentor.avgRating!.toStringAsFixed(1)),
                  if (mentor.totalReviews != null)
                    Text(
                      ' (${mentor.totalReviews})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  const SizedBox(width: 10),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

            // ── BUTTONS ─────────────────────────────────────
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      // ✅ PERUBAHAN: onPressed sekarang aktif → navigasi ke BookingPage
                      onPressed: isAvailable
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(mentor: mentor),
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isAvailable ? _primary : const Color(0xFFE0E0E0),
                        foregroundColor:
                            isAvailable ? Colors.white : Colors.grey.shade600,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: Colors.grey.shade600,
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAvailable ? Icons.calendar_month : Icons.block,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAvailable ? 'Book Session' : 'Not Available',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── QUICK INFO ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    'Price',
                    mentor.pricePerSession != null
                        ? _currency.format(mentor.pricePerSession)
                        : '-',
                  ),
                  _infoItem(
                    'Reviews',
                    mentor.totalReviews?.toString() ?? '-',
                  ),
                  _infoItem(
                    'Rating',
                    mentor.avgRating != null
                        ? mentor.avgRating!.toStringAsFixed(1)
                        : '-',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── ABOUT ────────────────────────────────────────
            _section(
              title: 'About',
              content: (mentor.bio != null && mentor.bio!.isNotEmpty)
                  ? mentor.bio!
                  : 'Mentor profesional di bidang '
                      '${mentor.categoryName ?? "mentoring"}. '
                      'Siap membantu kamu berkembang 🚀',
            ),

            // ── REVIEWS (placeholder) ────────────────────────
            Padding(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: null, // sementara dinonaktifkan
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Reviews coming soon',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── JADWAL TERSEDIA ──────────────────────────────
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
                    const Text(
                      'Available Schedules',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Builder(builder: (_) {
                      final available =
                          mentor.schedules.where((s) => !s.isBooked).toList();

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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${sched.availableDate} • ${sched.startTime}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Available',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  // ─────────────────────────────────────────────────────────────
  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
