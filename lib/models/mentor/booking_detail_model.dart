class ScheduleBookingDetailModel {
  final String  bookingId;
  final String  bookingStatus;   // Pending / Accepted / Rejected / Done
  final String? notes;           // pesan dari client
  final String  sessionType;     // 'Online' / 'Offline'
  final String? sessionLink;     // zoom link atau nama lokasi

  final String   scheduleId;
  final DateTime availableDate;
  final String   startTime;      // "HH:mm"
  final String?  endTime;        // "HH:mm"

  // ── Dari appuser (client)
  final String  clientId;
  final String  clientName;      // nama_lengkap
  final String? clientEmail;     // dari appuser.email

  // ── Dari bio_profil (client)
  final String? clientPhone;     // nomor_hp
  final String? clientPhotoUrl;  // foto_url
  final String? clientAddress;   // alamat

  // ── Dari categories (via bio_profil)
  final String? categoryName;

  const ScheduleBookingDetailModel({
    required this.bookingId,
    required this.bookingStatus,
    this.notes,
    required this.sessionType,
    this.sessionLink,
    required this.scheduleId,
    required this.availableDate,
    required this.startTime,
    this.endTime,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientPhotoUrl,
    this.clientAddress,
    this.categoryName,
  });

  factory ScheduleBookingDetailModel.fromJson(Map<String, dynamic> json) {
    // bookings → mentor_schedules (one-to-one via FK schedule_id)
    final schedule =
        json['mentor_schedules'] as Map<String, dynamic>? ?? {};

    // bookings → appuser (client via FK client_id)
    final client =
        json['appuser'] as Map<String, dynamic>? ?? {};

    // appuser → bio_profil (one-to-one via FK user_id)
    final rawBio = client['bio_profil'];
    Map<String, dynamic> bio = {};
    if (rawBio is List && rawBio.isNotEmpty) {
      bio = rawBio.first as Map<String, dynamic>;
    } else if (rawBio is Map) {
      bio = rawBio as Map<String, dynamic>;
    }

    // bio_profil → categories (one-to-one via FK category_id)
    final category =
        bio['categories'] as Map<String, dynamic>?;

    return ScheduleBookingDetailModel(
      bookingId:     json['id']             as String,
      bookingStatus: json['booking_status'] as String? ?? 'Pending',
      notes:         json['notes']          as String?,
      sessionType:   json['session_type']   as String? ?? 'Online',
      sessionLink:   json['session_link']   as String?,

      scheduleId:    schedule['id']             as String? ?? '',
      availableDate: schedule['available_date'] != null
          ? DateTime.parse(schedule['available_date'] as String)
          : DateTime.now(),
      startTime: _normalizeTime(schedule['start_time'] as String? ?? ''),
      endTime:   schedule['end_time'] != null
          ? _normalizeTime(schedule['end_time'] as String)
          : null,

      clientId:    client['id']           as String? ?? '',
      clientName:  client['nama_lengkap'] as String? ?? 'Unknown Client',
      clientEmail: client['email']        as String?,

      clientPhone:    bio['nomor_hp']  as String?,
      clientPhotoUrl: bio['foto_url']  as String?,
      clientAddress:  bio['alamat']    as String?,

      categoryName: category?['category_name'] as String?,
    );
  }

  /// "09:00 - 11:00" atau "09:00" bila end_time null
  String get timeRange =>
      (endTime != null && endTime!.isNotEmpty)
          ? '$startTime - $endTime'
          : startTime;

  /// "Senin, 20 April 2026"
  String get formattedDate {
    const weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${weekdays[availableDate.weekday - 1]}, '
        '${availableDate.day} '
        '${months[availableDate.month - 1]} '
        '${availableDate.year}';
  }

  static String _normalizeTime(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
