/// Model untuk satu record di tabel mentor_earnings
///
/// JOIN:
///   mentor_earnings
///     └── payments (via payment_id)
///           └── bookings (via booking_id)
///                 └── appuser AS client (via client_id)
class MentorEarningsModel {
  final String   id;
  final String   mentorId;
  final String   paymentId;
  final double   grossAmount;
  final double   platformFee;
  final double   netAmount;
  final DateTime createdAt;

  // ── Dari payments ────────────────────────────────────
  final String? paymentMethod;
  final String? paymentStatus;

  // ── Dari bookings → appuser (client) ────────────────
  final String? clientName;
  final String? clientFotoUrl;

  // ── Dari bookings ────────────────────────────────────
  final DateTime? sessionDate;     // dari mentor_schedules.available_date
  final String?   sessionStart;   // session_start_time

  const MentorEarningsModel({
    required this.id,
    required this.mentorId,
    required this.paymentId,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.createdAt,
    this.paymentMethod,
    this.paymentStatus,
    this.clientName,
    this.clientFotoUrl,
    this.sessionDate,
    this.sessionStart,
  });

  factory MentorEarningsModel.fromJson(Map<String, dynamic> json) {
    final payment  = json['payments']                   as Map<String, dynamic>?;
    final booking  = payment?['bookings']               as Map<String, dynamic>?;
    final client   = booking?['appuser']                as Map<String, dynamic>?;
    final schedule = booking?['mentor_schedules']       as Map<String, dynamic>?;

    // foto_url dari bio_profil (sudah di-join di controller)
    final bio      = json['_bio']                       as Map<String, dynamic>?;

    return MentorEarningsModel(
      id:          json['id']           as String,
      mentorId:    json['mentor_id']    as String,
      paymentId:   json['payment_id']   as String,
      grossAmount: (json['gross_amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      netAmount:   (json['net_amount']   as num).toDouble(),
      createdAt:   DateTime.parse(json['created_at'] as String),

      paymentMethod: payment?['payment_method'] as String?,
      paymentStatus: payment?['payment_status'] as String?,

      clientName:    client?['nama_lengkap'] as String?,
      clientFotoUrl: bio?['foto_url']        as String?,

      sessionDate: schedule?['available_date'] != null
          ? DateTime.tryParse(schedule!['available_date'] as String)
          : null,
      sessionStart: booking?['session_start_time'] != null
          ? _norm(booking!['session_start_time'] as String)
          : null,
    );
  }

  // ── Getters ────────────────────────────────────────

  /// "10 Mei 2026"
  String get dateLabel {
    final d = sessionDate ?? createdAt;
    const months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// "10 Mei 2026 • 09:00"
  String get dateTimeLabel {
    if (sessionStart != null) return '$dateLabel • $sessionStart';
    return dateLabel;
  }

  /// String YYYY-MM-DD untuk sort
  String get sortKey =>
      (sessionDate ?? createdAt).toIso8601String().substring(0, 10);

  static String _norm(String raw) {
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }
}