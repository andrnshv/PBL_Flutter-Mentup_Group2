class UserModel {
  final String username;
  final String token;
  final String name;
  final String image;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'image': image,
    };
  }
}