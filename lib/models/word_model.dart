import 'package:json_annotation/json_annotation.dart';
// import 'education_model.dart';
part 'word_model.g.dart';
// part 'education_model.g.dart';

///
///
/// define a schema for your class and annotate
/// and then run
/// ```flutter pub run build_runner build```
/// to watch the file changes and generate the outpur
/// ```flutter pub run build_runner watch```
// @JsonSerializable()
// class UserModel {
//   final String name;
//   final String email;
//   final Word education;
//   final String phone;
//   final DateTime date;

//   UserModel(this.name, this.email, this.phone, this.date, this.education);
//   factory UserModel.fromJson(Map<String, dynamic> json) =>
//       _$UserModelFromJson(json);
//   Map<String, dynamic> toJson() => _$UserModelToJson(this);
// }

@JsonSerializable()
class Word {
  final String id;
  final String word;

  Word(this.id, this.word);
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
