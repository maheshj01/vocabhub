import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/service_base.dart';

class DashboardController extends ChangeNotifier implements ServiceBase {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Word? _wordOfTheDay;
  late final DashboardService _dashboardService;
  final List<Word> _words = [];

  List<Word> get words => _words;

  set words(List<Word> words) {
    _words.clear();
    _words.addAll(words);
    notifyListeners();
    _dashboardService.setWords(words);
  }

  Word get wordOfTheDay => _wordOfTheDay ?? Word.init();

  set wordOfTheDay(Word word) {
    _wordOfTheDay = word;
    notifyListeners();
  }

  bool get isWodPublishedToday {
    final now = DateTime.now().toUtc();
    final differenceInHours = now.difference(_wordOfTheDay!.created_at!).inHours;
    return differenceInHours < 24;
  }

  Future<bool> publishWod(Word word) async {
    final response = await _dashboardService.publishWod(word);
    _wordOfTheDay = response.data as Word;
    notifyListeners();
    return response.didSucced;
  }

  Future<Word> getLastPublishedWord() async {
    final _lastWord = await _dashboardService.getLastPublishedWod();
    await _dashboardService.setPublishedWord(_lastWord);
    return _lastWord;
  }

  @override
  Future<void> initService() async {
    try {
      isLoading = true;
      if (_wordOfTheDay == null) {
        _wordOfTheDay = Word.init();
      }
      _dashboardService = DashboardService();
      await _dashboardService.initService();
      _wordOfTheDay = await getLastPublishedWord();
      words = await _dashboardService.getWords();
      isLoading = false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disposeService() async {}
}
