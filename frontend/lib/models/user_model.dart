class UserModel {
  final String username;
  final String token;
  final String name;
  final String image;

  UserModel({required this.username, required this.token, required this.name, required this.image});

  // Contoh OOP: Constructor untuk mengubah JSON dari backend menjadi Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(username: json['username'], token: json['token'], name: json['name'], image: json['image']);
  }
}
