class MyScheduleModel {
  // ── Kolom utama mentor_schedules ───────────────────────
  final String   id;
  final DateTime availableDate;
  final String   startTime; // "HH:mm"
  final String?  endTime;   // "HH:mm"
  final bool     isBooked;

  // ── Dari BOOKINGS (nullable) ────────────────────────────
  final String? bookingId;
  final String? bookingStatus; // Pending / Accepted / Rejected / Done
  final String? sessionType;   // 'Online' / 'Offline'
  final String? sessionLink;   // zoom url atau nama lokasi

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
    this.sessionType,
    this.sessionLink,
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
      id:            json['id'] as String,
      availableDate: DateTime.parse(json['available_date'] as String),
      startTime:     _normalizeTime(json['start_time'] as String? ?? ''),
      endTime:       json['end_time'] != null
                         ? _normalizeTime(json['end_time'] as String)
                         : null,
      isBooked:      json['is_booked'] as bool? ?? false,

      bookingId:     booking?['id'] as String?,
      bookingStatus: booking?['booking_status'] as String?,
      sessionType:   booking?['session_type'] as String?,
      sessionLink:   booking?['session_link'] as String?,

      clientId:   client?['id'] as String?,
      clientName: client?['nama_lengkap'] as String?,
    );
  }


  /// "09:00 - 11:00" atau "09:00" jika end_time null
  String get timeRange =>
      endTime != null && endTime!.isNotEmpty
          ? '$startTime - $endTime'
          : startTime;

  /// True jika ada booking aktif (bukan Rejected)
  bool get hasActiveBooking =>
      isBooked &&
      bookingStatus != null &&
      bookingStatus != 'Rejected';

  /// "20 Apr 2026"
  String get dateLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
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