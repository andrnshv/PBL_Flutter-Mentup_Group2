// ── Booking Request (status: paid) ──────────────────────────────
class MentorBookingRequestItem {
  final String bookingId;
  final String clientName;
  final String? clientFotoUrl;
  final String? categoryName;
  final String? availableDate; // dari mentor_schedules
  final String? sessionStartTime;
  final String? sessionEndTime;

  const MentorBookingRequestItem({
    required this.bookingId,
    required this.clientName,
    this.clientFotoUrl,
    this.categoryName,
    this.availableDate,
    this.sessionStartTime,
    this.sessionEndTime,
  });

  factory MentorBookingRequestItem.fromJson(Map<String, dynamic> json) {
    final client = json['appuser'] as Map<String, dynamic>?;
    final schedule = json['mentor_schedules'] as Map<String, dynamic>?;

    return MentorBookingRequestItem(
      bookingId: json['id'] as String,
      clientName: client?['nama_lengkap'] as String? ?? 'Unknown',
      clientFotoUrl: json['foto_url'] as String?, // ← flat
      categoryName: json['category_name'] as String?, // ← flat
      availableDate: schedule?['available_date'] as String?,
      sessionStartTime: _norm(json['session_start_time'] as String?),
      sessionEndTime: _norm(json['session_end_time'] as String?),
    );
  }

  /// "21 Apr"
  String get dateLabel {
    if (availableDate == null) return '-';
    try {
      final dt = DateTime.parse(availableDate!);
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
        'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return availableDate!;
    }
  }

  /// "09:00" atau "09:00 - 11:00"
  String get timeLabel {
    if (sessionStartTime == null) return '-';
    if (sessionEndTime == null) return sessionStartTime!;
    return '$sessionStartTime - $sessionEndTime';
  }

  static String? _norm(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }
}

// ── Upcoming Session (status: confirmed) ────────────────────────
class MentorUpcomingSession {
  final String bookingId;
  final String clientName;
  final String? categoryName;
  final String? availableDate;
  final String? sessionStartTime;
  final String? sessionEndTime;
  final String? clientAddress;

  const MentorUpcomingSession({
    required this.bookingId,
    required this.clientName,
    this.categoryName,
    this.availableDate,
    this.sessionStartTime,
    this.sessionEndTime,
    this.clientAddress,
  });

  factory MentorUpcomingSession.fromJson(Map<String, dynamic> json) {
    final client = json['appuser'] as Map<String, dynamic>?;
    final schedule = json['mentor_schedules'] as Map<String, dynamic>?;

    return MentorUpcomingSession(
      bookingId: json['id'] as String,
      clientName: client?['nama_lengkap'] as String? ?? 'Unknown',
      categoryName: json['category_name'] as String?, // ← flat
      availableDate: schedule?['available_date'] as String?,
      sessionStartTime: _norm(json['session_start_time'] as String?),
      sessionEndTime: _norm(json['session_end_time'] as String?),
      clientAddress: json['client_address'] as String?,
    );
  }

  /// "Senin, 21 Apr 2026"
  String get dateLabel {
    if (availableDate == null) return '-';
    try {
      final dt = DateTime.parse(availableDate!);
      const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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
        'Des'
      ];
      return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return availableDate!;
    }
  }

  String get timeLabel {
    if (sessionStartTime == null) return '-';
    if (sessionEndTime == null) return sessionStartTime!;
    return '$sessionStartTime - $sessionEndTime';
  }

  static String? _norm(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }
}

// ── Recent Review ────────────────────────────────────────────────
class MentorReviewItem {
  final String reviewId;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;
  final String clientName;
  final String? clientFotoUrl;

  const MentorReviewItem({
    required this.reviewId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    required this.clientName,
    this.clientFotoUrl,
  });

  factory MentorReviewItem.fromJson(Map<String, dynamic> json) {
    final client = json['appuser'] as Map<String, dynamic>?;

    return MentorReviewItem(
      reviewId: json['id'] as String,
      rating: json['rating'] as int? ?? 0,
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      clientName: client?['nama_lengkap'] as String? ?? 'Unknown',
      clientFotoUrl: json['foto_url'] as String?, // ← flat
    );
  }

  String get initial =>
      clientName.isNotEmpty ? clientName[0].toUpperCase() : '?';
}

// ── Mentor Profile (foto + nama) ─────────────────────────────────
class MentorProfileSummary {
  final String nama;
  final String? fotoUrl;

  const MentorProfileSummary({required this.nama, this.fotoUrl});

  factory MentorProfileSummary.fromJson(Map<String, dynamic> json) {
    return MentorProfileSummary(
      nama: json['nama_lengkap'] as String? ?? 'Mentor',
      fotoUrl: json['foto_url'] as String?,
    );
  }
}
