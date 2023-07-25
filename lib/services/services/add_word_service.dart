import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/service_base.dart';

class AddWordService extends ServiceBase {
  late SharedPreferences _sharedPreferences;

  final kWordDraft = 'kWordDraft';

  List<Word> getWordFromDraft() {
    try {
      final wordString = _sharedPreferences.getString(kWordDraft) ?? '';
      if (wordString.isEmpty) {
        return [];
      } else {
        final decoded = json.decode(wordString);
        return decoded.map<Word>((e) => Word.fromJson(e)).toList();
      }
    } catch (_) {
      throw "Failed to load drafts";
    }
  }

  Future<void> setWordToDraft(List<Word> words) async {
    final encoded = json.encode(words);
    await _sharedPreferences.setString(kWordDraft, encoded);
  }

  @override
  Future<void> disposeService() async {}

  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }
}
