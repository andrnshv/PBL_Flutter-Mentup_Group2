///                 + SERVICE_RATES + MENTOR_SCHEDULES
class MentorProfileModel {
  // Identitas
  final String userId;
  final String namaLengkap;
  final String? fotoUrl;
  final String? bio;
  final String? alamat;
  final String? nomorHp;

  final String? categoryName;
  final String? universityName;

  final int? pricePerSession;

  final double? avgRating;
  final int? totalReviews;

  final List<MentorScheduleItem> schedules;

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
  });

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) {
    final bio = json['bio_profil'] as Map<String, dynamic>?;
    final category = bio?['categories'] as Map<String, dynamic>?;
    final univ = bio?['universities'] as Map<String, dynamic>?;
    final rates = json['service_rates'] as List<dynamic>?;
    final rawSched = json['mentor_schedules'] as List<dynamic>?;

    return MentorProfileModel(
      userId: json['id'] as String,
      namaLengkap: bio?['nama_lengkap'] as String? ??
          json['nama_lengkap'] as String? ??
          '-',
      fotoUrl: bio?['foto_url'] as String?,
      bio: bio?['bio'] as String?,
      alamat: bio?['alamat'] as String?,
      nomorHp: bio?['nomor_hp'] as String?,
      categoryName: category?['category_name'] as String?,
      universityName: univ?['university_name'] as String?,
      pricePerSession: rates != null && rates.isNotEmpty
          ? (rates.first['price_per_session'] as num?)?.toInt()
          : null,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
      schedules: rawSched
              ?.map(
                  (s) => MentorScheduleItem.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MentorScheduleItem {
  final String id;
  final String availableDate;
  final String startTime;
  final bool isBooked;

  MentorScheduleItem({
    required this.id,
    required this.availableDate,
    required this.startTime,
    required this.isBooked,
  });

  factory MentorScheduleItem.fromJson(Map<String, dynamic> json) {
    return MentorScheduleItem(
      id: json['id'] as String,
      availableDate: json['available_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      isBooked: json['is_booked'] as bool? ?? false,
    );
  }
}
