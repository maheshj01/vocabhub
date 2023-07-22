import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';

part 'history.g.dart';

///
///
/// define a schema for your class and annotate
/// and then run
/// ```flutter pub run build_runner build --delete-conflicting-outputs```
/// to watch the file changes and generate the outpur
/// ```flutter pub run build_runner watch```

@JsonSerializable()
class EditHistory {
  final String? edit_id;
  String email;
  String word_id;
  String word;
  String meaning;
  List<String>? synonyms;
  List<String>? examples;
  List<String>? mnemonics;
  DateTime? created_at;
  EditState? state;
  EditType? edit_type;

  /// edit details of user (property should be table name)
  UserModel? users_mobile;

  EditHistory(
      {this.edit_id,
      required this.word_id,
      required this.email,
      required this.word,
      required this.meaning,
      this.state = EditState.pending,
      this.edit_type = EditType.edit,
      this.created_at,
      this.synonyms = const [],
      this.examples = const [],
      this.users_mobile,
      this.mnemonics = const []});

  factory EditHistory.fromJson(Map<String, dynamic> json) => _$EditHistoryFromJson(json);

  EditHistory copyWith({
    String? edit_id,
    String? user_email,
    String? word_id,
    String? word,
    String? meaning,
    List<String>? synonyms = const [],
    List<String>? examples = const [],
    List<String>? mnemonics = const [],
    DateTime? created_at,
    EditState? state,
    EditType? edit_type,
    UserModel? users_mobile,
  }) {
    return EditHistory(
      edit_id: edit_id ?? this.edit_id,
      email: user_email ?? this.email,
      word_id: word_id ?? this.word_id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      synonyms: synonyms!.isEmpty ? this.synonyms : synonyms,
      examples: examples!.isEmpty ? this.examples : examples,
      mnemonics: mnemonics!.isEmpty ? this.mnemonics : mnemonics,
      created_at: created_at ?? this.created_at,
      state: state ?? this.state,
      edit_type: edit_type ?? this.edit_type,
      users_mobile: users_mobile ?? this.users_mobile,
    );
  }

  factory EditHistory.fromWord(Word word, String email) {
    return EditHistory(
      word: word.word,
      created_at: word.created_at,
      email: email,
      meaning: word.meaning,
      examples: word.examples,
      mnemonics: word.mnemonics,
      synonyms: word.synonyms,
      word_id: word.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditHistory &&
          runtimeType == other.runtimeType &&
          edit_id == other.edit_id &&
          word == other.word &&
          word == other.word &&
          created_at == other.created_at &&
          state == other.state &&
          email == other.email &&
          word_id == other.word_id &&
          edit_type == other.edit_type;

  @override
  int get hashCode => edit_id.hashCode ^ word.hashCode;

  Map<String, dynamic> toJson() => _$EditHistoryToJson(this);
}
