class UserModel {
  final String username;
  final String token;

  UserModel({required this.username, required this.token});

  // Contoh OOP: Constructor untuk mengubah JSON dari backend menjadi Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(username: json['username'], token: json['token']);
  }
}
