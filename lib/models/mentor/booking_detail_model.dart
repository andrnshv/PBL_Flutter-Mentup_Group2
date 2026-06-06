class ScheduleBookingDetailModel {
  final String bookingId;
  final String
      bookingStatus; // pending / paid / confirmed / rejected / done / dst
  final String? notes; // pesan dari client (atau alasan reject)

  final String scheduleId;
  final DateTime availableDate;
  final String startTime; // "HH:mm" (range slot mentor)
  final String? endTime; // "HH:mm"

  // ── Jam sesi yang dibooking client ──
  final String? sessionStartTime; // "HH:mm"
  final String? sessionEndTime; // "HH:mm"

  // ── Dari appuser (client)
  final String clientId;
  final String clientName; // nama_lengkap
  final String? clientEmail; // dari appuser.email

  // ── Dari bio_profil (client)
  final String? clientPhone; // nomor_hp
  final String? clientPhotoUrl; // foto_url
  final String? clientBioAddress; // alamat di bio_profil client

  // ── Alamat sesi (disimpan saat booking) ──
  final String? clientAddress; // bookings.client_address

  // ── Dari categories (via bio_profil)
  final String? categoryName;

  final String? rescheduleReason; // alasan reschedule dari mentor

  const ScheduleBookingDetailModel({
    required this.bookingId,
    required this.bookingStatus,
    this.notes,
    required this.scheduleId,
    required this.availableDate,
    required this.startTime,
    this.endTime,
    this.sessionStartTime,
    this.sessionEndTime,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientPhotoUrl,
    this.clientBioAddress,
    this.clientAddress,
    this.categoryName,
    this.rescheduleReason,
  });

  factory ScheduleBookingDetailModel.fromJson(Map<String, dynamic> json) {
    final schedule = json['mentor_schedules'] as Map<String, dynamic>? ?? {};

    final client = json['appuser'] as Map<String, dynamic>? ?? {};

    final rawBio = client['bio_profil'];
    Map<String, dynamic> bio = {};
    if (rawBio is List && rawBio.isNotEmpty) {
      bio = rawBio.first as Map<String, dynamic>;
    } else if (rawBio is Map) {
      bio = rawBio as Map<String, dynamic>;
    }

    final category = bio['categories'] as Map<String, dynamic>?;

    return ScheduleBookingDetailModel(
      bookingId: json['id'] as String,
      bookingStatus: json['booking_status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      scheduleId: schedule['id'] as String? ?? '',
      availableDate: schedule['available_date'] != null
          ? DateTime.parse(schedule['available_date'] as String)
          : DateTime.now(),
      startTime: _normalizeTime(schedule['start_time'] as String? ?? ''),
      endTime: schedule['end_time'] != null
          ? _normalizeTime(schedule['end_time'] as String)
          : null,
      sessionStartTime: json['session_start_time'] != null
          ? _normalizeTime(json['session_start_time'] as String)
          : null,
      sessionEndTime: json['session_end_time'] != null
          ? _normalizeTime(json['session_end_time'] as String)
          : null,
      clientId: client['id'] as String? ?? '',
      clientName: client['nama_lengkap'] as String? ?? 'Unknown Client',
      clientEmail: client['email'] as String?,
      clientPhone: bio['nomor_hp'] as String?,
      clientPhotoUrl: bio['foto_url'] as String?,
      clientBioAddress: bio['alamat'] as String?,
      clientAddress: json['client_address'] as String?,
      categoryName: category?['category_name'] as String?,
      rescheduleReason: json['reschedule_reason'] as String?,
    );
  }

  /// Range slot mentor "09:00 - 11:00"
  String get timeRange => (endTime != null && endTime!.isNotEmpty)
      ? '$startTime - $endTime'
      : startTime;

  /// Jam sesi booking client "10:00 - 12:00" (fallback ke slot mentor)
  String get sessionTimeRange {
    if (sessionStartTime != null) {
      return sessionEndTime != null
          ? '$sessionStartTime - $sessionEndTime'
          : sessionStartTime!;
    }
    return timeRange;
  }

  /// Durasi sesi dalam jam (dari session time, fallback slot)
  String get durationLabel {
    final start = sessionStartTime ?? startTime;
    final end = sessionEndTime ?? endTime;
    if (end == null) return '-';
    final s = start.split(':');
    final e = end.split(':');
    final mins = (int.parse(e[0]) * 60 + int.parse(e[1])) -
        (int.parse(s[0]) * 60 + int.parse(s[1]));
    if (mins <= 0) return '-';
    final h = mins / 60.0;
    final label = h == h.roundToDouble() ? h.toInt().toString() : h.toString();
    return '$label Hours';
  }

  /// Alamat sesi: pakai client_address (yang disimpan saat booking),
  /// fallback ke alamat bio_profil client.
  String get sessionAddress {
    if (clientAddress != null && clientAddress!.isNotEmpty) {
      return clientAddress!;
    }
    if (clientBioAddress != null && clientBioAddress!.isNotEmpty) {
      return clientBioAddress!;
    }
    return '-';
  }

  /// "Senin, 20 April 2026"
  String get formattedDate {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
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
