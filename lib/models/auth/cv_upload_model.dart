class CvUploadModel {
  final String userId;
  final String namaLengkap;
  final String email;
  final String cvUrl;
  final String status;
  final DateTime createdAt;

  CvUploadModel({
    required this.userId,
    required this.namaLengkap,
    required this.email,
    required this.cvUrl,
    required this.status,
    required this.createdAt,
  });

  factory CvUploadModel.fromJson(Map<String, dynamic> json) {
    return CvUploadModel(
      userId: json['user_id'],
      namaLengkap: json['nama_lengkap'],
      email: json['email'],
      cvUrl: json['cv_url'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'email': email,
      'cv_url': cvUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}