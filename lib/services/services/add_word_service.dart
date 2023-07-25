import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/service_base.dart';

class AddWordService extends ServiceBase {
  late SharedPreferences _sharedPreferences;

  final kWordDraft = 'kWordDraft';

  Word getWordFromDraft() {
    final wordString = _sharedPreferences.getString(kWordDraft) ?? '';
    if (wordString.isEmpty) {
      return Word.init();
    } else {
      final decoded = json.decode(wordString);
      return Word.fromJson(decoded);
    }
  }

  Future<void> setWordToDraft(Word word) async {
    final encoded = json.encode(word.toJson());
    await _sharedPreferences.setString(kWordDraft, encoded);
  }

  @override
  Future<void> disposeService() async {}

  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }
}
