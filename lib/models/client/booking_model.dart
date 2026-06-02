class BookingFormModel {
  final String scheduleId;
  final String availableDate; // "YYYY-MM-DD"
  final String startTime; // "HH:mm"
  final String? endTime; // "HH:mm"

  const BookingFormModel({
    required this.scheduleId,
    required this.availableDate,
    required this.startTime,
    this.endTime,
  });

  factory BookingFormModel.fromJson(Map<String, dynamic> json) {
    return BookingFormModel(
      scheduleId: json['id'] as String,
      availableDate: json['available_date'] as String? ?? '',
      startTime: _fmt(json['start_time'] as String? ?? ''),
      endTime:
          json['end_time'] != null ? _fmt(json['end_time'] as String) : null,
    );
  }

  static String _fmt(String raw) {
    final p = raw.split(':');
    if (p.length < 2) return raw;
    return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
  }

  /// Convert "YYYY-MM-DD" jadi DateTime (untuk dipakai di kalender)
  DateTime get dateTime {
    final p = availableDate.split('-');
    if (p.length < 3) return DateTime.now();
    return DateTime(
      int.parse(p[0]),
      int.parse(p[1]),
      int.parse(p[2]),
    );
  }

  /// "Sen, 21 Apr 2026 • 09:00 - 11:00"
  String get displayLabel {
    final dt = dateTime;
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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
    final time = endTime != null ? '$startTime - $endTime' : startTime;
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year} • $time';
  }
}
