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
  final String id;
  String user_id;
  String word_id;
  Word word;
  WordEditState state;
  DateTime? created_at;

  EditHistory(
      {required this.id,
      required this.word,
      required this.created_at,
      required this.state,
      required this.user_id,
      required this.word_id});

  factory EditHistory.fromJson(Map<String, dynamic> json) =>
      _$EditHistoryFromJson(json);

  EditHistory copyWith({
    String? id,
    Word? word,
    DateTime? created_at,
    WordEditState? state,
    String? user_id,
    String? word_id,
  }) {
    return EditHistory(
        id: id ?? this.id,
        word: word ?? this.word,
        created_at: created_at ?? this.created_at,
        state: state ?? this.state,
        user_id: user_id ?? this.user_id,
        word_id: word_id ?? this.word_id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word &&
          word == other.word &&
          created_at == other.created_at &&
          state == other.state &&
          user_id == other.user_id &&
          word_id == other.word_id;

  @override
  int get hashCode => id.hashCode ^ word.hashCode;

  Map<String, dynamic> toJson() => _$EditHistoryToJson(this);
}
