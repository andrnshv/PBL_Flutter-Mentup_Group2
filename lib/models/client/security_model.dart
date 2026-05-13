class SecurityModel {
  final String email;

  SecurityModel({
    required this.email,
  });

  factory SecurityModel.fromJson(Map<String, dynamic> json) {
    return SecurityModel(
      email: json['email'] ?? '',
    );
  }
}