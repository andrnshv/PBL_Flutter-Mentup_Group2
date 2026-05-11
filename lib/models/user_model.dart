class UserModel {
  final String username;
  final String token;
  final String name;
  final String email;
  final String password;
  final String image;
  final String bio;
  final String address;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.email,
    required this.password,
    required this.image,
    required this.bio,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      image: json['image'] ?? '',
      bio: json['bio'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'email': email,
      'password': password,
      'image': image,
      'bio': bio,
      'address': address,
    };
  }

  /// ================= COPY WITH =================

  UserModel copyWith({
    String? username,
    String? token,
    String? name,
    String? email,
    String? password,
    String? image,
    String? bio,
    String? address,
  }) {
    return UserModel(
      username: username ?? this.username,
      token: token ?? this.token,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      address: address ?? this.address,
    );
  }
}