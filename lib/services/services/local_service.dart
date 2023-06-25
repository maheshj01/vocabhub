import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/service_base.dart';

class LocalService extends ServiceBase {
  late SharedPreferences _sharedPreferences;
  final String kAllWords = 'kAllWords';

  List<Word> _localWords = [];

  List<Word> get localWords => _localWords;

  Future<void> setLocalWords(List<Word> value) async {
    _localWords.clear();
    _localWords.addAll(value);
    final stringWords = value.map((e) => jsonEncode(e.toJson())).toList();
    await _sharedPreferences.setStringList(kAllWords, stringWords);
  }

  Future<List<Word>> getLocalWords() async {
    final stringWords = _sharedPreferences.getStringList(kAllWords) ?? [];
    final words = stringWords.map((e) => Word.fromJson(jsonDecode(e))).toList();
    _localWords = words;
    return words;
  }

  @override
  Future<void> disposeService() async {
    _localWords.clear();
  }

  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    getLocalWords();
  }
}
