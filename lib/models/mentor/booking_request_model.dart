/// Model untuk satu item di BookingRequestPage (Mentor side)
///
/// Query JOIN:
///   bookings
///     ├── appuser AS client (via client_id)
///     │     └── bio_profil  (via email — query terpisah)
///     └── mentor_schedules  (via schedule_id)
///
/// Kolom bookings yang dipakai (skema terbaru):
///   id, booking_status, notes, created_at,
///   session_start_time, session_end_time, client_address
class BookingRequestModel {
  final String bookingId;
  final String bookingStatus; // pending/paid/confirmed/rejected/dll
  final String? notes;
  final DateTime createdAt;

  // ── Waktu sesi (dari bookings langsung) ────────────────
  final String? sessionStartTime; // "HH:mm"
  final String? sessionEndTime; // "HH:mm"
  final String? clientAddress;

  // ── Jadwal mentor (dari mentor_schedules) ───────────────
  final DateTime? scheduleDate; // available_date

  // ── Client info (dari appuser) ─────────────────────────
  final String clientId;
  final String clientName;
  final String? clientEmail;

  // ── Bio client (dari bio_profil — query terpisah) ──────
  final String? clientFotoUrl;
  final String? categoryName; // dari bio_profil.categories

  const BookingRequestModel({
    required this.bookingId,
    required this.bookingStatus,
    this.notes,
    required this.createdAt,
    this.sessionStartTime,
    this.sessionEndTime,
    this.clientAddress,
    this.scheduleDate,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientFotoUrl,
    this.categoryName,
  });

  // ── fromJson dari query 1 (tanpa bio_profil) ────────────
  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    final client = json['appuser'] as Map<String, dynamic>?;
    final schedule = json['mentor_schedules'] as Map<String, dynamic>?;

    return BookingRequestModel(
      bookingId: json['id'] as String,
      bookingStatus: json['booking_status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),

      sessionStartTime: _norm(json['session_start_time'] as String?),
      sessionEndTime: _norm(json['session_end_time'] as String?),
      clientAddress: json['client_address'] as String?,

      scheduleDate: schedule?['available_date'] != null
          ? DateTime.tryParse(schedule!['available_date'] as String)
          : null,

      clientId: client?['id'] as String? ?? '',
      clientName: client?['nama_lengkap'] as String? ?? 'Unknown',
      clientEmail: client?['email'] as String?,

      // Bio diisi setelah query 2
      clientFotoUrl: null,
      categoryName: null,
    );
  }

  /// Buat salinan dengan bio_profil yang sudah diisi
  BookingRequestModel withBio({
    String? fotoUrl,
    String? category,
  }) {
    return BookingRequestModel(
      bookingId: bookingId,
      bookingStatus: bookingStatus,
      notes: notes,
      createdAt: createdAt,
      sessionStartTime: sessionStartTime,
      sessionEndTime: sessionEndTime,
      clientAddress: clientAddress,
      scheduleDate: scheduleDate,
      clientId: clientId,
      clientName: clientName,
      clientEmail: clientEmail,
      clientFotoUrl: fotoUrl,
      categoryName: category,
    );
  }

  // ── Getters ────────────────────────────────────────────

  /// "21 Apr 2026"
  String get dateLabel {
    final d = scheduleDate ?? createdAt;
    const months = [
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// "09:00" atau "09:00 - 11:00"
  String get timeLabel {
    if (sessionStartTime == null) return '-';
    if (sessionEndTime == null) return sessionStartTime!;
    return '$sessionStartTime - $sessionEndTime';
  }

  /// Normalisasi status ke Title Case untuk display
  String get statusDisplay {
    if (bookingStatus.isEmpty) return 'Pending';
    return bookingStatus[0].toUpperCase() + bookingStatus.substring(1);
  }

  /// Group tab: 'Pending' | 'Accepted' | 'Rejected'
  String get tabGroup {
    switch (bookingStatus.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'confirmed':
      case 'done':
      case 'completed':
      case 'awaiting_verification':
        return 'Accepted';
      case 'rejected':
      case 'cancelled':
      case 'failed':
        return 'Rejected';
      default:
        return 'Paid'; // fallback
    }
  }

  static String? _norm(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }
}
