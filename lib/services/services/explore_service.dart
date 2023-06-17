import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/services/services/vocabstore.dart';

class ExploreService {
  final _logger = Logger('ExploreService');

  static Future<List<Word>> exploreWords(String email, {int page = 0}) async {
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
  }
}
