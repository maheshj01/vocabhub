import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/explore_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class ExploreController extends ChangeNotifier with ServiceBase {
  final Duration _autoScrollDuration = Duration(seconds: 10);
  late DateTime _scrollMessageShownDate;
  late bool _isScrollMessageShown;
  late bool _isHidden;
  late PageController _pageController;

  PageController get pageController => _pageController;

  set pageController(PageController value) {
    _pageController = value;
    notifyListeners();
  }

  set scrollToIndex(int index) {
    _pageController.animateToPage(index,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  int index() {
    return _pageController.page!.toInt();
  }

  bool get isHidden => _isHidden;

  DateTime get scrollMessageShownDate => _scrollMessageShownDate;

  bool get isScrollMessageShown => _isScrollMessageShown;

  late final ExploreService _exploreService;

  bool _shouldShowScrollMessage = false;

  bool get shouldShowScrollMessage => _shouldShowScrollMessage;

  void setShouldShowScrollMessage() {
    if (!isScrollMessageShown) {
      _shouldShowScrollMessage = true;
      return;
    }
    final shownDate = scrollMessageShownDate;
    final now = DateTime.now();
    final differenceInDays = shownDate.difference(now).inDays;
    _shouldShowScrollMessage = differenceInDays > Constants.scrollMessageShownInterval;
  }

  @override
  Future<void> initService() async {
    _isHidden = true;
    _scrollMessageShownDate = DateTime.now();
    _pageController = PageController();
    _exploreService = ExploreService();
    await _exploreService.initService();
    _isHidden = await _exploreService.getExploreHidden();
    setIsScrollMessageShown(await _exploreService.getIsScrollMessageShown());
    _scrollMessageShownDate = await _exploreService.getScrollMessageShownDate();
  }

  Future<void> hideExplore(bool value) async {
    _isHidden = value;
    notifyListeners();
    await _exploreService.setExploreHidden(value);
  }

  Future<void> setIsScrollMessageShown(bool value) async {
    _isScrollMessageShown = value;
    notifyListeners();
    await _exploreService.setIsScrollMessageShown(value);
    if (isScrollMessageShown) {
      setShouldShowScrollMessage();
    }
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
  Future<void> disposeService() async {
    _pageController.dispose();
  }
}
