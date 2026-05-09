class UserModel {
  final String username;
  final String token;
  final String name;
  final String image;
  final String bio;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.image,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'image': image,
      'bio': bio,
    };
  }
}