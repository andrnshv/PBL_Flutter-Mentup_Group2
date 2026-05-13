class RegisterModel {
  final String namaLengkap;
  final String username;
  final String email;
  final String password;
  final String role;

  RegisterModel({
    required this.namaLengkap,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama_lengkap': namaLengkap,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}