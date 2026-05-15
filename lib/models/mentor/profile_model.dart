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

  factory MentorProfileModel.fromMap(Map<String, dynamic> appuser, Map<String, dynamic>? bio) {
    return MentorProfileModel(
      namaLengkap  : appuser['nama_lengkap'] ?? '',
      username     : appuser['username']     ?? '',
      bio          : bio?['bio']             ?? '',
      keahlian     : bio?['keahlian']        ?? '',
      universitas  : bio?['universitas']     ?? '',
      fotoUrl      : bio?['foto_url'],
    );
  }
}