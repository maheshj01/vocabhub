import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/logger.dart';

class DashboardService extends ServiceBase {
  late SharedPreferences _sharedPreferences;
  final kwordOfTheDay = 'kwordOfTheDay';
  final kWords = 'kWords';
  late Logger _logger;

//   Future<void> setWodPublished(bool value) async {
//     await _sharedPreferences.setBool(kIsWodPublished, value);
//   }

//   Future<bool> getWodPublished() async {
//     return _sharedPreferences.getBool(kIsWodPublished) ?? false;
//   }

  Future<void> setPublishedWord(Word word) async {
    await _sharedPreferences.setString(kwordOfTheDay, jsonEncode(word.toJson()));
  }

  Future<bool> publishWod(Word word) async {
    final response = await VocabStoreService.publishWod(word);
    if (response.didSucced) {
      await setPublishedWord((response.data as Word));
    }
    return response.didSucced;
  }

  /// This method is used to get the last published date time from the shared preferences.
  /// If the date time is not available in the shared preferences, then it will fetch the last
  /// updated record from the database in UTC.
  Future<Word> getLastPublishedWod() async {
    try {
      final String? wordString = _sharedPreferences.getString(kwordOfTheDay) ?? '';
      if (wordString != null && wordString.isNotEmpty) {
        // decode the json string to word object
        final decodedString = jsonDecode(wordString);
        final Word word = Word.fromJson(decodedString as Map<String, dynamic>);
        setPublishedWord(word);
        return word;
      } else {
        final Word wodFromServer = await VocabStoreService.getLastUpdatedRecord();
        setPublishedWord(wodFromServer);
        return wodFromServer;
      }
    } catch (e) {
      _logger.e(e.toString());
      rethrow;
    }
  }

  Future<void> setWords(List<Word> words) async {
    final List<String> wordsString = words.map((e) => jsonEncode(e.toJson())).toList();
    await _sharedPreferences.setStringList(kWords, wordsString);
  }

  Future<List<Word>> getWords() async {
    final List<String>? wordsString = _sharedPreferences.getStringList(kWords);
    if (wordsString != null && wordsString.isNotEmpty) {
      final List<Word> words = wordsString.map((e) => Word.fromJson(jsonDecode(e))).toList();
      return words;
    } else {
      return await VocabStoreService.getAllWords();
    }
  }

  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _logger = Logger("DashboardService");
  }

  @override
  Future<void> disposeService() async {}
}
