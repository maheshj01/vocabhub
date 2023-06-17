import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/service_base.dart';

class SearchService extends ServiceBase {
  late SharedPreferences _sharedPreferences;
  static const signedInKey = 'isSignedIn';
  static const emailKey = 'emailKey';
  static const skipCountKey = 'skipCount';
  static const recentKey = 'recent';
  static const maxSkipCount = 3;
  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<List<Word>> get recents async {
    final recentList = _sharedPreferences.getString('$recentKey') ?? '[]';
    final List<Word> recentWords = [];
    final words = jsonDecode(recentList);
    for (final word in words) {
      recentWords.add(Word.fromJson(word));
    }
    return recentWords;
  }

  Future<void> addRecent(Word word) async {
    final List<Word> recentList = await recents;
    if (!recentList.contains(word)) {
      recentList.add(word);
      setRecents(recentList);
    }
  }

  Future<void> removeRecent(Word value) async {
    final List<Word> recentList = await recents;
    recentList.remove(value);
    setRecents(recentList);
  }

  Future<void> setRecents(List<Word> words) async {
    final stringData = jsonEncode(words);
    await _sharedPreferences.setString(recentKey, stringData);
  }

  Future<void> clearSearchHistory() async {
    await _sharedPreferences.remove(recentKey);
  }

  @override
  Future<void> disposeService() async {}
}
