class MentorProfileModel {

  final String namaLengkap;
  final String username;
  final String bio;
  final String keahlian;
  final String universitas;
  final String? fotoUrl;

  MentorProfileModel({
    required this.namaLengkap,
    required this.username,
    required this.bio,
    required this.keahlian,
    required this.universitas,
    this.fotoUrl,
  });

  factory MentorProfileModel.fromMap(
    Map<String, dynamic> appuser,
    Map<String, dynamic>? bio,
  ) {

    final category =
        bio?['categories'];

    final university =
        bio?['universities'];

    return MentorProfileModel(
      namaLengkap : appuser['nama_lengkap'] ?? '',
      username    : appuser['username'] ?? '',
      bio         : bio?['bio'] ?? '',

      keahlian : category != null
          ? category['category_name'] ?? ''
          : '',

      universitas : university != null
          ? university['university_name'] ?? ''
          : '',

      fotoUrl : bio?['foto_url'],
    );
  }
}