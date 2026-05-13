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

  factory ProfileModel.fromMap({
    required Map<String, dynamic> appuser,
    Map<String, dynamic>? bio,
  }) {
    return ProfileModel(
      namaLengkap: appuser['nama_lengkap'] ?? '',
      username: appuser['username'] ?? '',
      bio: bio?['bio'] ?? 'No bio yet.',
      fotoUrl: bio?['foto_url'],
    );
  }
}