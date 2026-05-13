class ProfileModel {
  final String namaLengkap;
  final String username;
  final String bio;
  final String? fotoUrl;

  ProfileModel({
    required this.namaLengkap,
    required this.username,
    required this.bio,
    this.fotoUrl,
  });
}