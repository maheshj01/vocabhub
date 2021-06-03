import 'package:json_annotation/json_annotation.dart';
// import 'education_model.dart';
part 'user_model.g.dart';
// part 'education_model.g.dart';

///
///
/// define a schema for your class and annotate
/// and then run
/// ```flutter pub run build_runner build ```
/// to watch the file changes and generate the outpur
/// ```flutter pub run build_runner watch ```
@JsonSerializable(nullable: false)
class UserModel {
  final String name;
  final String email;
  final Education education;
  final String phone;
  final DateTime date;

  UserModel(this.name, this.email, this.phone, this.date, this.education);
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable(nullable: false)
class Education {
  final String major;
  final String university;
  final int coolness;

  Education(this.major, this.university, this.coolness);
  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
