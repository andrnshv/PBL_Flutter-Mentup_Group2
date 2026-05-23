import 'package:google_maps_flutter/google_maps_flutter.dart';

class MentorSearchModel {
  final String userId;
  final String namaLengkap;
  final String? fotoUrl;
  final String? bio;
  final String? alamat;
  final String? categoryName;
  final int? pricePerSession;
  final double? rating;
  final double? latitude;
  final double? longitude;

  MentorSearchModel({
    required this.userId,
    required this.namaLengkap,
    this.fotoUrl,
    this.bio,
    this.alamat,
    this.categoryName,
    this.pricePerSession,
    this.rating,
    this.latitude,
    this.longitude,
  });

  factory MentorSearchModel.fromJson(Map<String, dynamic> json) {
    final bio = json['bio_profil'] as Map<String, dynamic>?;
    final category = bio?['categories'] as Map<String, dynamic>?;
    final rates = json['service_rates'] as List<dynamic>?;

    return MentorSearchModel(
      userId: json['id'] as String,
      namaLengkap: bio?['nama_lengkap'] as String? ??
          json['nama_lengkap'] as String? ??
          '-',
      fotoUrl: bio?['foto_url'] as String?,
      bio: bio?['bio'] as String?,
      alamat: bio?['alamat'] as String?,
      categoryName: category?['category_name'] as String?,
      pricePerSession: rates != null && rates.isNotEmpty
          ? (rates.first['price_per_session'] as num?)?.toInt()
          : null,
      rating: (json['avg_rating'] as num?)?.toDouble(),
      latitude: (bio?['latitude'] as num?)?.toDouble(),
      longitude: (bio?['longitude'] as num?)?.toDouble(),
    );
  }

  // Koordinat fallback untuk highlight kamera Google Maps berdasarkan domisili
  static const Map<String, LatLng> cityCoordinates = {
    'Malang City': LatLng(-7.9653, 112.6214),
    'Malang': LatLng(-7.9653, 112.6214),
    'Surabaya': LatLng(-7.2575, 112.7521),
    'Jakarta': LatLng(-6.2088, 106.8456),
    'Bandung': LatLng(-6.9175, 107.6191),
    'Yogyakarta': LatLng(-7.7956, 110.3695),
  };
}
