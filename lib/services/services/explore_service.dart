import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/services/services/service_base.dart';

class ExploreService extends ServiceBase {
  final _logger = Logger('ExploreService');
  late SharedPreferences _sharedPreferences;
  final kExploreHiddenKey = 'kExploreHiddenKey';
  final kScrollMessageShownDateKey = 'kScrollMessageShownDateKey';
  final kIsScrollMessageShownKey = 'kIsScrollMessageShownKey';
  @override
  Future<void> initService() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<List<Word>> exploreWords(String email, {int page = 0}) async {
    try {
      // get All words
      final response = await DatabaseService.findLimitedWords(sort: false);
      final masteredWords = await VocabStoreService.getBookmarks(email, isBookmark: false);
      List<Word> words = [];
      final List<Word> _exploreWords = [];
      if (response.status == 200) {
        words = (response.data as List).map((e) => Word.fromJson(e)).toList();
        words.shuffle();

        /// exclude words that are already bookmarked.
        words.forEach((element) {
          if (!masteredWords.contains(element)) {
            _exploreWords.add(element);
          }
        });
      }
      return _exploreWords;
    } catch (_) {
      _logger.e(_.toString());
      return localService.localWords;
    }
  }

  Future<void> setScrollMessageShownDate(DateTime date) {
    return _sharedPreferences.setString(kScrollMessageShownDateKey, date.toString());
  }

  Future<DateTime> getScrollMessageShownDate() async {
    final String? date = _sharedPreferences.getString(kScrollMessageShownDateKey);
    if (date != null) {
      return DateTime.parse(date);
    }
    return DateTime.now();
  }

  Future<void> setIsScrollMessageShown(bool value) async {
    await setScrollMessageShownDate(DateTime.now());
    await _sharedPreferences.setBool(kIsScrollMessageShownKey, value);
  }

  Future<bool> getIsScrollMessageShown() async {
    return _sharedPreferences.getBool(kIsScrollMessageShownKey) ?? false;
  }

  Future<bool> getExploreHidden() async {
    return _sharedPreferences.getBool(kExploreHiddenKey) ?? false;
  }

  Future<void> setExploreHidden(bool value) async {
    await _sharedPreferences.setBool(kExploreHiddenKey, value);
  }

  @override
  Future<void> disposeService() async {}
}
