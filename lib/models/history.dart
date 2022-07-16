import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/constants/const.dart';
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
  String user_email;
  String word_id;
  String word;
  String meaning;
  List<String>? synonyms;
  List<String>? examples;
  List<String>? mnemonics;
  DateTime? created_at;
  WordEditState state;

  EditHistory(
      {this.edit_id,
      required this.word_id,
      required this.user_email,
      required this.word,
      required this.meaning,
      this.state = WordEditState.pending,
      this.created_at,
      this.synonyms = const [],
      this.examples = const [],
      this.mnemonics = const []});

  factory EditHistory.fromJson(Map<String, dynamic> json) =>
      _$EditHistoryFromJson(json);

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
    WordEditState? state,
  }) {
    return EditHistory(
      edit_id: edit_id ?? this.edit_id,
      user_email: user_email ?? this.user_email,
      word_id: word_id ?? this.word_id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      synonyms: synonyms!.isEmpty ? this.synonyms : synonyms,
      examples: examples!.isEmpty ? this.examples : examples,
      mnemonics: mnemonics!.isEmpty ? this.mnemonics : mnemonics,
      created_at: created_at ?? this.created_at,
      state: state!,
    );
  }

  // factory EditHistory.fromWord(Word word) {
  //   return EditHistory(
  //     word: word,
  //     created_at: this.created_at,
  //     state: this.state,
  //     user_email: user_email,
  //     word_id: word.id,
  //   );
  // }

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
          user_email == other.user_email &&
          word_id == other.word_id;

  @override
  int get hashCode => edit_id.hashCode ^ word.hashCode;

  Map<String, dynamic> toJson() => _$EditHistoryToJson(this);
}
