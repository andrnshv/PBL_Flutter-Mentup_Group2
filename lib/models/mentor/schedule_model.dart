class MyScheduleModel {
  // ── Kolom utama mentor_schedules ───────────────────────
  final String id;
  final DateTime availableDate;
  final String startTime; // "HH:mm" (range slot mentor)
  final String? endTime; // "HH:mm"
  final bool isBooked;

  // ── Dari BOOKINGS (nullable) ────────────────────────────
  final String? bookingId;
  final String? bookingStatus; // pending / confirmed / done / dst
  final String? sessionStartTime; // jam mulai booking client "HH:mm"
  final String? sessionEndTime; // jam selesai booking client "HH:mm"
  final String? clientAddress; // alamat sesi (offline)

  // ── Dari APPUSER client (nullable) ─────────────────────
  final String? clientId;
  final String? clientName;

  const MyScheduleModel({
    required this.id,
    required this.availableDate,
    required this.startTime,
    this.endTime,
    required this.isBooked,
    this.bookingId,
    this.bookingStatus,
    this.sessionStartTime,
    this.sessionEndTime,
    this.clientAddress,
    this.clientId,
    this.clientName,
  });

  factory MyScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawBookings = json['bookings'];
    Map<String, dynamic>? booking;

    if (rawBookings is List && rawBookings.isNotEmpty) {
      booking = rawBookings.first as Map<String, dynamic>;
    } else if (rawBookings is Map) {
      booking = rawBookings as Map<String, dynamic>;
    }

    final rawClient = booking?['appuser'];
    Map<String, dynamic>? client;
    if (rawClient is Map) {
      client = rawClient as Map<String, dynamic>;
    }

    return MyScheduleModel(
      id: json['id'] as String,
      availableDate: DateTime.parse(json['available_date'] as String),
      startTime: _normalizeTime(json['start_time'] as String? ?? ''),
      endTime: json['end_time'] != null
          ? _normalizeTime(json['end_time'] as String)
          : null,
      isBooked: json['is_booked'] as bool? ?? false,
      bookingId: booking?['id'] as String?,
      bookingStatus: booking?['booking_status'] as String?,
      sessionStartTime: booking?['session_start_time'] != null
          ? _normalizeTime(booking!['session_start_time'] as String)
          : null,
      sessionEndTime: booking?['session_end_time'] != null
          ? _normalizeTime(booking!['session_end_time'] as String)
          : null,
      clientAddress: booking?['client_address'] as String?,
      clientId: client?['id'] as String?,
      clientName: client?['nama_lengkap'] as String?,
    );
  }

  /// Range slot mentor: "09:00 - 11:00" atau "09:00" jika end null
  String get timeRange => endTime != null && endTime!.isNotEmpty
      ? '$startTime - $endTime'
      : startTime;

  /// Jam sesi yang dibooking client: "10:00 - 12:00" (kalau ada)
  String? get sessionTimeRange {
    if (sessionStartTime == null) return null;
    return sessionEndTime != null
        ? '$sessionStartTime - $sessionEndTime'
        : sessionStartTime;
  }

  /// True jika ada booking aktif (bukan dibatalkan/gagal)
  bool get hasActiveBooking =>
      isBooked &&
      bookingStatus != null &&
      bookingStatus != 'cancelled' &&
      bookingStatus != 'failed' &&
      bookingStatus != 'rejected';

  /// "20 Apr 2026"
  String get dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${availableDate.day} '
        '${months[availableDate.month - 1]} '
        '${availableDate.year}';
  }

  /// "09:00:00" → "09:00"
  static String _normalizeTime(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
