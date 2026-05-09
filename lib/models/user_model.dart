class UserModel {
  final String username;
  final String token;
  final String name;
  final String email;
  final String image;
  final String bio;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.email,
    required this.image,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'email' : email,
      'image': image,
      'bio': bio,
    };
  }
}