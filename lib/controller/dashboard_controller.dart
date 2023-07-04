import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/dashboard_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class DashboardController extends ChangeNotifier with ServiceBase {
  late Word _lastPublishedWord;
  late final DashboardService _dashboardService;

  Word get lastPublishedWord => _lastPublishedWord;

  bool get isWodPublishedToday {
    final now = DateTime.now().toUtc();
    final differenceInHours = now.difference(_lastPublishedWord.created_at!).inHours;
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

  @override
  Future<void> initService() async {
    try {
      _dashboardService = DashboardService();
      await _dashboardService.initService();
      _lastPublishedWord = await _dashboardService.getLastPublishedWod();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disposeService() async {}
}
