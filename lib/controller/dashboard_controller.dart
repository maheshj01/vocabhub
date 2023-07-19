import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/dashboard_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class DashboardController extends ChangeNotifier with ServiceBase {
  Word? _lastPublishedWord;
  late final DashboardService _dashboardService;

  Word get lastPublishedWord => _lastPublishedWord ?? Word.init();

  bool get isWodPublishedToday {
    final now = DateTime.now().toUtc();
    final differenceInHours = now.difference(_lastPublishedWord!.created_at!).inHours;
    return differenceInHours < 24;
  }

  Future<void> setPublishedWord(Word word) async {
    _lastPublishedWord = word;
    notifyListeners();
    _dashboardService.setPublishedWord(word);
  }

  Future<bool> publishWod(Word word) async {
    return await _dashboardService.publishWod(word);
  }

  Future<Word> getLastPublishedWord() async {
    final _lastWord = await _dashboardService.getLastPublishedWod();
    await setPublishedWord(_lastWord);
    return _lastWord;
  }

  @override
  Future<void> initService() async {
    try {
      if (_lastPublishedWord == null) {
        _lastPublishedWord = Word.init();
      }
      _dashboardService = DashboardService();
      await _dashboardService.initService();
      _lastPublishedWord = await getLastPublishedWord();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disposeService() async {}
}
