class ClientReviewModel {
  final String reviewId;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;
  final String clientName;
  final String? clientFotoUrl;
  final String? categoryName;

  const ClientReviewModel({
    required this.reviewId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    required this.clientName,
    this.clientFotoUrl,
    this.categoryName,
  });

  factory ClientReviewModel.fromJson(Map<String, dynamic> json) {
    final client = json['appuser'] as Map<String, dynamic>?;

    return ClientReviewModel(
      reviewId: json['id'] as String,
      rating: json['rating'] as int? ?? 0,
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      clientName: client?['nama_lengkap'] as String? ?? 'Unknown',
      clientFotoUrl: json['foto_url'] as String?, // flat dari controller
      categoryName: json['category_name'] as String?, // flat dari controller
    );
  }

  String get initial =>
      clientName.isNotEmpty ? clientName[0].toUpperCase() : '?';

  /// "21 Apr 2026 • 14:00"
  String get dateTimeLabel {
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
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year} • $h:$m';
  }
}
