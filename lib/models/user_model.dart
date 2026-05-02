class UserModel {
  final String username;
  final String token;
  final String name;
  final String image;
  final String role;
  final String bio;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.image,
    required this.role,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      role: json['role'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'image': image,
      'role': role,
      'bio': bio,
    };
  }
}