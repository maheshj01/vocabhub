import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/dashboardstate.dart';
import 'package:vocabhub/services/services.dart';

class DashboardStateNotifier extends StateNotifier<AsyncValue<DashboardState>> {
  DashboardStateNotifier(this.sharedPreferences, this.vocabStore, this.ref)
      : super(AsyncValue.loading()) {
    init();
  }

  VocabStoreService vocabStore;
  Ref? ref;

  Future<void> init() async {
    state = AsyncValue.loading();
    try {
      final user = ref!.read(userNotifierProvider).value!;
      final wordOfTheDay = await VocabStoreService.getLastUpdatedRecord();
      final words = await VocabStoreService.getAllWords();
      List<Word> bookMarks = [];
      if (user.isLoggedIn) {
        bookMarks = await VocabStoreService.getBookmarks(user.email);
      }
      state = AsyncValue.data(
        DashboardState(
          wordOfTheDay: wordOfTheDay,
          words: words,
          bookMarks: bookMarks,
        ),
      );
    } catch (e, y) {
      state = AsyncValue.error(e, y);
    }
  }

  DashboardState get stateValue => AsyncValue.data(state.asData!.value).value!;

  final SharedPreferences sharedPreferences;

  final String kWordOfTheDay = 'kWordOfTheDay';
  final String kWords = 'kWords';
  final String kBookMarks = 'kBookMarks';

  void setWordOfTheDay(Word value) {
    state = AsyncValue.data(state.value!.copyWith(wordOfTheDay: value));
    final String word = value.toJson();
    sharedPreferences.setString(kWordOfTheDay, word);
  }

  void setWords(List<Word> value) {
    state = AsyncValue.data(state.value!.copyWith(words: value));
    final String words = value.map((e) => e.toJson()).toList().toString();
    sharedPreferences.setString(kWords, words);
  }

  void setBookMarks(List<Word> value) {
    AsyncValue.data(state.value!.copyWith(bookMarks: value));
    final String bookMarks = value.map((e) => e.toJson()).toList().toString();
    sharedPreferences.setString(kBookMarks, bookMarks);
  }

  Future<Word>? getWordOfTheDay() async {
    final wod = await VocabStoreService.getLastUpdatedRecord();
    setWordOfTheDay(wod);
    return wod;
    // final String? word = sharedPreferences.getString(kWordOfTheDay);
    // final decoded = json.decode(word!);
    // if (decoded != null) {
    //   final wod = Word.fromJson(decoded);
    //   state = AsyncValue.data(state.value!.copyWith(wordOfTheDay: wod));
    //   return wod;
    // } else {
    //   return Word.init();
    // }
  }

  Future<List<Word>>? getWords() async {
    final words = await VocabStoreService.getAllWords();
    setWords(words);
    return words;
    // final String? words = sharedPreferences.getString(kWords);
    // final decoded = json.decode(words!);
    // if (decoded != null) {
    //   final words = List<Word>.from(decoded.map((x) => Word.fromJson(x)));
    //   state = AsyncValue.data(state.value!.copyWith(words: words));
    //   return words;
    // } else {
    //   return [];
    // }
  }

  Future<List<Word>>? getBookMarks() async {
    final user = ref!.read(userNotifierProvider).value!;
    if (user.isLoggedIn) {
      final bookmarks = await VocabStoreService.getBookmarks(user.email);
      return bookmarks;
    }
    return [];
    // final String? bookMarks = sharedPreferences.getString(kBookMarks);
    // final decoded = json.decode(bookMarks!);
    // if (decoded != null) {
    //   return List<Word>.from(decoded.map(Word.fromJson));
    // } else {
    //   return null;
    // }
  }

  /// get latest word of the day sort by descending order of created_at
  /// check current DateTime UTC and compare with the latest word of the day
  /// if the date is same, then don't publish a new word of the day
  /// else publish a new word of the day

  /// todo word of the day
  Future<void> publishWordOfTheDay({bool isRefresh = false}) async {
    // state = AsyncValue.loading();
    // try {
    //   // If word of the day already published then get word of the day
    //   if (dashboardController.isWodPublishedToday) {
    //     if (isRefresh) {
    //       final word = await dashboardController.getLastPublishedWord();
    //       dashboardController.wordOfTheDay = word;
    //       return;
    //     }
    //     final publishedWod = dashboardController.wordOfTheDay;
    //     state = AsyncValue.data(
    //       state.value!.copyWith(wordOfTheDay: publishedWod),
    //     );
    //     return;
    //   }
    //   final allWords = dashboardController.words;
    //   final random = Random();
    //   final randomWord = allWords[random.nextInt(allWords.length)];
    //   final success = await dashboardController.publishWod(randomWord);
    //   if (success) {
    //     pushNotificationService.sendNotificationToTopic(PushNotificationService.wordOfTheDayTopic,
    //         'Word of the Day: ${randomWord.word} ', 'Tap to see word of the day');
    //   } else {}
    // } catch (e) {
    //   state = AsyncError(e, StackTrace.current);
    // }
  }
}
