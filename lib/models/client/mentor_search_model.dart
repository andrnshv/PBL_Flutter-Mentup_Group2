class MentorSearchModel {
  final String userId;
  final String namaLengkap;
  final String? fotoUrl;
  final String? bio;
  final String? alamat; // dipakai sebagai domisili
  final String? categoryName;
  final int? pricePerSession;
  final double? rating;

  MentorSearchModel({
    required this.userId,
    required this.namaLengkap,
    this.fotoUrl,
    this.bio,
    this.alamat,
    this.categoryName,
    this.pricePerSession,
    this.rating,
  });

  factory MentorSearchModel.fromJson(Map<String, dynamic> json) {
    final bio = json['bio_profil'] as Map<String, dynamic>?;
    final category = bio?['categories'] as Map<String, dynamic>?;
    final rates = json['service_rates'] as List<dynamic>?;

    return MentorSearchModel(
      userId: json['id'] as String,
      namaLengkap: bio?['nama_lengkap'] as String? ?? json['nama_lengkap'] as String? ?? '-',
      fotoUrl: bio?['foto_url'] as String?,
      bio: bio?['bio'] as String?,
      alamat: bio?['alamat'] as String?,
      categoryName: category?['category_name'] as String?,
      pricePerSession: rates != null && rates.isNotEmpty
          ? (rates.first['price_per_session'] as num?)?.toInt()
          : null,
      rating: (json['avg_rating'] as num?)?.toDouble(),
    );
  }
}