class MentorModel {
  final String name;
  final String category;
  final String image;
  final double rating;
  final int price;
  final double distance;
  final String? phone;

  MentorModel({
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.price,
    required this.distance,
    this.phone,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      price: json['price'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'image': image,
      'rating': rating,
      'price': price,
      'distance': distance,
      'phone': phone,
    };
  }
}