class EditProfileModel {
  final String namaLengkap;
  final String email;
  final String bio;
  final String? fotoUrl;

  EditProfileModel({
    required this.namaLengkap,
    required this.email,
    required this.bio,
    this.fotoUrl,
  });
}