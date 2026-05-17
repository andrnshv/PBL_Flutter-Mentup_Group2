class MentorEditProfileModel {

  final String namaLengkap;
  final String username;
  final String nomorHp;
  final String alamat;
  final String bio;

  final String? categoryName;
  final String? universityName;

  final String? fotoUrl;
  final String? cvUrl;

  MentorEditProfileModel({
    required this.namaLengkap,
    required this.username,
    required this.nomorHp,
    required this.alamat,
    required this.bio,
    this.categoryName,
    this.universityName,
    this.fotoUrl,
    this.cvUrl,
  });

  factory MentorEditProfileModel.fromMap(
    Map<String, dynamic> appuser,
    Map<String, dynamic>? bio,
    Map<String, dynamic>? cv,
  ) {

    return MentorEditProfileModel(

      namaLengkap : appuser['nama_lengkap'] ?? '',
      username    : appuser['username'] ?? '',

      nomorHp     : bio?['nomor_hp'] ?? '',
      alamat      : bio?['alamat'] ?? '',
      bio          : bio?['bio'] ?? '',

      categoryName:
          bio?['categories']?['category_name'],

      universityName:
          bio?['universities']?['university_name'],

      fotoUrl     : bio?['foto_url'],
      cvUrl       : cv?['cv_url'],
    );
  }
}