class MentorProfileModel {
  final String  userId;
  final String  namaLengkap;
  final String? fotoUrl;
  final String? bio;
  final String? alamat;
  final String? nomorHp;
  final String? categoryName;
  final String? universityName;
  final int?    pricePerSession;
  final double? avgRating;
  final int?    totalReviews;
  final List<MentorScheduleItem> schedules;
  final List<MentorReviewItem>   reviews;   // ← BARU

  MentorProfileModel({
    required this.userId,
    required this.namaLengkap,
    this.fotoUrl,
    this.bio,
    this.alamat,
    this.nomorHp,
    this.categoryName,
    this.universityName,
    this.pricePerSession,
    this.avgRating,
    this.totalReviews,
    this.schedules = const [],
    this.reviews   = const [],  // ← BARU
  });

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) {
    final bio      = json['bio_profil']       as Map<String, dynamic>?;
    final category = bio?['categories']       as Map<String, dynamic>?;
    final univ     = bio?['universities']     as Map<String, dynamic>?;
    final rates    = json['service_rates']    as List<dynamic>?;
    final rawSched = json['mentor_schedules'] as List<dynamic>?;
    final rawRev   = json['reviews']          as List<dynamic>?; // ← BARU

    return MentorProfileModel(
      userId:      json['id']      as String,
      namaLengkap: bio?['nama_lengkap'] as String?
                   ?? json['nama_lengkap'] as String?
                   ?? '-',
      fotoUrl:        bio?['foto_url']        as String?,
      bio:            bio?['bio']             as String?,
      alamat:         bio?['alamat']          as String?,
      nomorHp:        bio?['nomor_hp']        as String?,
      categoryName:   category?['category_name']  as String?,
      universityName: univ?['university_name']    as String?,
      pricePerSession: rates != null && rates.isNotEmpty
          ? (rates.first['price_per_session'] as num?)?.toInt()
          : null,
      avgRating:    (json['avg_rating']    as num?)?.toDouble(),
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
      schedules: rawSched
              ?.map((s) => MentorScheduleItem.fromJson(
                    s as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: rawRev                              // ← BARU
              ?.map((r) => MentorReviewItem.fromJson(
                    r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Schedule item
// ─────────────────────────────────────────────────────────────
class MentorScheduleItem {
  final String id;
  final String availableDate;
  final String startTime;
  final bool   isBooked;

  MentorScheduleItem({
    required this.id,
    required this.availableDate,
    required this.startTime,
    required this.isBooked,
  });

  factory MentorScheduleItem.fromJson(Map<String, dynamic> json) {
    return MentorScheduleItem(
      id:            json['id']             as String,
      availableDate: json['available_date'] as String? ?? '',
      startTime:     json['start_time']     as String? ?? '',
      isBooked:      json['is_booked']      as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Review item — dari tabel reviews + appuser (client)
// ─────────────────────────────────────────────────────────────
class MentorReviewItem {
  final String   id;
  final int      rating;       // 1-5
  final String?  reviewText;
  final DateTime createdAt;

  // ── Info client (reviewer) ──────────────────────────
  final String  clientId;
  final String  clientName;
  final String? clientFotoUrl;

  MentorReviewItem({
    required this.id,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    required this.clientId,
    required this.clientName,
    this.clientFotoUrl,
  });

  factory MentorReviewItem.fromJson(Map<String, dynamic> json) {
    // client dari JOIN appuser:client_id (alias di controller)
    final client = json['reviewer'] as Map<String, dynamic>?;
    final bio    = json['_bio']     as Map<String, dynamic>?;

    return MentorReviewItem(
      id:           json['id']          as String,
      rating:       (json['rating']     as num?)?.toInt() ?? 0,
      reviewText:   json['review_text'] as String?,
      createdAt:    DateTime.parse(
                      json['created_at'] as String? ??
                      DateTime.now().toIso8601String()),
      clientId:      client?['id']           as String? ?? '',
      clientName:    client?['nama_lengkap'] as String? ?? 'Anonymous',
      clientFotoUrl: bio?['foto_url']        as String?,
    );
  }

  /// "10 Apr 2026"
  String get dateLabel {
    const months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}