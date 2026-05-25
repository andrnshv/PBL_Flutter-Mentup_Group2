/// Model untuk satu slot jadwal mentor.
///
/// Digunakan oleh dua halaman:
///   - MySchedulePage  : query JOIN lengkap (mentor_schedules + bookings + appuser)
///   - ManageSlotPage  : query simpel (mentor_schedules saja, tanpa join)
///
/// Skema tabel yang dibutuhkan:
///   MENTOR_SCHEDULES : id, mentor_id, available_date,
///                      start_time, end_time, is_booked
///   BOOKINGS         : id, schedule_id, client_id, booking_status,
///                      session_type, session_link
///   APPUSER (client) : id, nama_lengkap
class ManageSlotModel {
  // ── Kolom utama mentor_schedules ────────────────────────
  final String   id;
  final DateTime availableDate;
  final String   startTime; // format normal: "HH:mm"
  final String?  endTime;   // format normal: "HH:mm"
  final bool     isBooked;

  // ── Dari BOOKINGS (nullable — tidak ada jika belum di-booking) ──
  final String? bookingId;
  final String? bookingStatus; // Pending / Accepted / Rejected / Done
  final String? sessionType;   // 'Online' / 'Offline'
  final String? sessionLink;   // zoom/gmeet url atau nama lokasi offline

  // ── Dari APPUSER client (nullable) ──────────────────────
  final String? clientId;
  final String? clientName;

  const ManageSlotModel({
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

  // ─────────────────────────────────────────────────────────
  // FROM JSON
  // Aman untuk dua jenis response:
  //   (A) Query simpel  : hanya kolom mentor_schedules
  //   (B) Query JOIN    : + bookings + appuser
  // ─────────────────────────────────────────────────────────
  factory ManageSlotModel.fromJson(Map<String, dynamic> json) {
    // Booking: bisa list (one-to-many) atau null jika query simpel
    final rawBookings = json['bookings'];
    Map<String, dynamic>? booking;
    if (rawBookings is List && rawBookings.isNotEmpty) {
      booking = rawBookings.first as Map<String, dynamic>;
    } else if (rawBookings is Map) {
      // Jika Supabase mengembalikan object tunggal (bukan list)
      booking = rawBookings as Map<String, dynamic>;
    }

    // Client dari appuser di dalam bookings
    final rawClient = booking?['appuser'];
    Map<String, dynamic>? client;
    if (rawClient is Map) {
      client = rawClient as Map<String, dynamic>;
    }

    return ManageSlotModel(
      id:            json['id'] as String,
      availableDate: DateTime.parse(json['available_date'] as String),
      // Normalisasi "HH:mm:ss" → "HH:mm"
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

  // ─────────────────────────────────────────────────────────
  // TO JSON — untuk INSERT ke Supabase
  // mentor_id diisi di controller (dari auth), tidak disimpan di model
  // ─────────────────────────────────────────────────────────
  Map<String, dynamic> toInsertJson(String mentorId) => {
    'mentor_id':      mentorId,
    'available_date': '${availableDate.year}'
                      '-${availableDate.month.toString().padLeft(2, '0')}'
                      '-${availableDate.day.toString().padLeft(2, '0')}',
    'start_time':     '$startTime:00',  // Supabase TIME butuh "HH:mm:ss"
    'end_time':       endTime != null ? '$endTime:00' : null,
    'is_booked':      false,
  };

  // ─────────────────────────────────────────────────────────
  // COPY WITH — untuk update lokal tanpa fetch ulang
  // ─────────────────────────────────────────────────────────
  ManageSlotModel copyWith({
    String?   id,
    DateTime? availableDate,
    String?   startTime,
    String?   endTime,
    bool?     isBooked,
    String?   bookingId,
    String?   bookingStatus,
    String?   sessionType,
    String?   sessionLink,
    String?   clientId,
    String?   clientName,
  }) {
    return ManageSlotModel(
      id:            id            ?? this.id,
      availableDate: availableDate ?? this.availableDate,
      startTime:     startTime     ?? this.startTime,
      endTime:       endTime       ?? this.endTime,
      isBooked:      isBooked      ?? this.isBooked,
      bookingId:     bookingId     ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      sessionType:   sessionType   ?? this.sessionType,
      sessionLink:   sessionLink   ?? this.sessionLink,
      clientId:      clientId      ?? this.clientId,
      clientName:    clientName    ?? this.clientName,
    );
  }

  // ─────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────

  /// Format tampil: "09:00 - 11:00" atau "09:00" jika end_time null
  String get timeRange =>
      endTime != null && endTime!.isNotEmpty
          ? '$startTime - $endTime'
          : startTime;

  /// True jika slot ini sudah ada booking aktif (bukan Rejected)
  bool get hasActiveBooking =>
      isBooked &&
      bookingStatus != null &&
      bookingStatus != 'Rejected';

  /// Label tanggal: "20 Apr 2026"
  String get dateLabel {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${availableDate.day} '
           '${months[availableDate.month - 1]} '
           '${availableDate.year}';
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────

  /// Potong detik jika ada: "09:00:00" → "09:00"
  static String _normalizeTime(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}