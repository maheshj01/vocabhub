import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/logger.dart';

class DashboardService extends ServiceBase {
  late SharedPreferences _sharedPreferences;
  final kLastPublishedWord = 'kLastPublishedWord';
  late Logger _logger;

//   Future<void> setWodPublished(bool value) async {
//     await _sharedPreferences.setBool(kIsWodPublished, value);
//   }

//   Future<bool> getWodPublished() async {
//     return _sharedPreferences.getBool(kIsWodPublished) ?? false;
//   }

  Future<void> setPublishedWord(Word word) async {
    await _sharedPreferences.setString(kLastPublishedWord, jsonEncode(word.toJson()));
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
      // final String? wordString = _sharedPreferences.getString(kLastPublishedWord);
      // if (wordString != null) {
      //   // decode the json string to word object
      //   final decodedString = jsonDecode(wordString);
      //   final Word word = Word.fromJson(decodedString as Map<String, dynamic>);
      //   return word;
      // }
      final Word lastWod = await VocabStoreService.getLastUpdatedRecord();
      setPublishedWord(lastWod);
      return lastWod;
    } catch (e) {
      _logger.e(e.toString());
      rethrow;
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
