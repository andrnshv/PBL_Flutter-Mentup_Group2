class MentorEditProfileModel {
  final String namaLengkap;
  final String username;
  final String nomorHp;
  final String keahlian;
  final String universitas;
  final String alamat;
  final String bio;
  final String? fotoUrl;
  final String? cvUrl;

  MentorEditProfileModel({
    required this.namaLengkap,
    required this.username,
    required this.nomorHp,
    required this.keahlian,
    required this.universitas,
    required this.alamat,
    required this.bio,
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
      username    : appuser['username']     ?? '',
      nomorHp     : bio?['nomor_hp']        ?? '',
      keahlian    : bio?['keahlian']        ?? '',
      universitas : bio?['universitas']     ?? '',
      alamat      : bio?['alamat']          ?? '',
      bio         : bio?['bio']             ?? '',
      fotoUrl     : bio?['foto_url'],
      cvUrl       : cv?['cv_url'],
    );
  }
}