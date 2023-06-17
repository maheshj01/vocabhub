import 'package:flutter/material.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/explore_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class ExploreController extends ChangeNotifier with ServiceBase {
  final Duration _autoScrollDuration = Duration(seconds: 10);
  late bool _isHidden;
  bool get isHidden => _isHidden;
  late final ExploreService _exploreService;

  @override
  Future<void> initService() async {
    _isHidden = true;
    _exploreService = ExploreService();
    await _exploreService.initService();
    _isHidden = await _exploreService.getExploreHidden();
  }

  Future<void> hideExplore(bool value) async {
    _isHidden = value;
    notifyListeners();
    await _exploreService.setExploreHidden(value);
  }

  void toggleHiddenExplore() {
    _isHidden = !_isHidden;
    notifyListeners();
    _exploreService.setExploreHidden(_isHidden);
  }

  Future<List<Word>> exploreWords(String email, {int page = 0}) async {
    // get All words
    final List<Word> _exploreWords = await _exploreService.exploreWords(email);
    return _exploreWords;
  }

  @override
  Future<void> disposeService() async {}
}
