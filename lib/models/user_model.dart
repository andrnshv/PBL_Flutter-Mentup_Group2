class UserModel {
  final String username;
  final String token;
  final String name;
  final String image;
  final double rating;
  final String role;

  final String category;
  final int price;
  final double distance;

  final String? phone;

  UserModel({
    required this.username,
    required this.token,
    required this.name,
    required this.image,
    required this.rating,
    required this.role,
    required this.category,
    required this.price,
    required this.distance,

    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      role: json['role'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'token': token,
      'name': name,
      'image': image,
      'rating': rating,
      'role': role,
      'category': category,
      'price': price,
      'distance': distance,
      'phone': phone,
    };
  }
}