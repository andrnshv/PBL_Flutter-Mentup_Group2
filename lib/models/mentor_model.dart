import 'package:equatable/equatable.dart';

class MentorModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String category;
  final String education;
  final String image;
  final double rating;
  final int price;
  final double distance;
  final String? phone;

  const MentorModel({
    required this.id,
    required this.name,
    required this.username,
    required this.category,
    required this.education,
    required this.image,
    required this.rating,
    required this.price,
    required this.distance,
    this.phone,
  });

  MentorModel copyWith({
    String? id,
    String? name,
    String? username,
    String? category,
    String? education,
    String? image,
    double? rating,
    int? price,
    double? distance,
    String? phone,
  }) {
    return MentorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username?? this.username,
      category: category ?? this.category,
      education: education ?? this.education,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      phone: phone ?? this.phone,
    );
  }

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      category: json['category'] ?? '',
      education: json['education'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] ?? 0.0),
      price: json['price'] ?? 0,
      distance: (json['distance'] is int)
          ? (json['distance'] as int).toDouble()
          : (json['distance'] ?? 0.0),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'category': category,
      'education': education,
      'image': image,
      'rating': rating,
      'price': price,
      'distance': distance,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, username, category, education, image, rating, price, distance, phone];
}