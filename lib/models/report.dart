class ReportModel {
  final String id;
  final String email;
  final String name;
  final String feedback;
  final DateTime created_at;

  ReportModel({
    required this.id,
    required this.email,
    required this.name,
    required this.feedback,
    required this.created_at,
  });
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      feedback: json['feedback'],
      created_at: DateTime.parse(json['created_at']),
    );
  }

  ReportModel.copyWith({
    required this.id,
    required this.email,
    required this.name,
    required this.feedback,
    required this.created_at,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'feedback': feedback,
      'created_at': created_at.toIso8601String(),
    };
  }
}
