class ServiceRateModel {
  final String id;
  final String mentorId;
  final int pricePerSession;

  ServiceRateModel({
    required this.id,
    required this.mentorId,
    required this.pricePerSession,
  });

  factory ServiceRateModel.fromJson(Map<String, dynamic> json) {
    return ServiceRateModel(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      pricePerSession: (json['price_per_session'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mentor_id': mentorId,
        'price_per_session': pricePerSession,
      };
}