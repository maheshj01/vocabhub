import 'package:json_annotation/json_annotation.dart';
// import 'education_model.dart';
part 'word_model.g.dart';
// part 'education_model.g.dart';

///
///
/// define a schema for your class and annotate
/// and then run
/// ```flutter pub run build_runner build --delete-conflicting-outputs```
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
  String meaning;
  List<String>? synonyms;
  List<String>? examples;
  final String? note;

  Word(this.id, this.word, this.meaning,
      {this.synonyms = const [],
      // this.antonyms = const [],
      this.note,
      this.examples = const []});
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  factory Word.copyWith(Word w) {
    return Word(w.id, w.word, w.meaning,
        examples: w.examples, note: w.note, synonyms: w.synonyms);
  }

  Map<String, dynamic> toJson() => _$WordToJson(this);
}
