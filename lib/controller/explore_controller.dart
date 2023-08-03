import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/explore_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class ExploreController extends ChangeNotifier with ServiceBase {
  final Duration _autoScrollDuration = Duration(seconds: 10);
  late DateTime _scrollMessageShownDate;
  late bool _isScrollMessageShown = false;
  late final ExploreService _exploreService;
  List<Word> _exploreWords = [];

  Map<String, List<Word>> _collections = {};

  Map<String, List<Word>> get collections => _collections;

  List<Word> get exploreWords => _exploreWords;

  late bool _isHidden;
  late PageController _pageController;
  late bool _isAnimating = false;

  bool get isAnimating => _isAnimating;

  set isAnimating(bool value) {
    _isAnimating = value;
    notifyListeners();
  }

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

  /// whether the word detail is hidden on explore page
  bool get isHidden => _isHidden;

  DateTime get scrollMessageShownDate => _scrollMessageShownDate;

  bool get isScrollMessageShown => _isScrollMessageShown;

  bool _shouldShowScrollAnimation = true;

  bool get shouldShowScrollAnimation => _shouldShowScrollAnimation;

  Future<void> initShouldShowScrollAnimation() async {
    final now = DateTime.now();
    _isScrollMessageShown = await _exploreService.getIsScrollMessageShown();
    _scrollMessageShownDate = now;
    _scrollMessageShownDate = await _exploreService.getScrollMessageShownDate();
    final differenceInDays = now.difference(scrollMessageShownDate).inDays;
    _shouldShowScrollAnimation = differenceInDays >= Constants.scrollMessageShownInterval;
  }

  Future<void> initCollections() async {
    _collections = await _exploreService.getCollections();
    notifyListeners();
  }

  Future<void> addToCollection(String collectionName, Word word) async {
    await _exploreService.addToCollection(collectionName, word);
    await initCollections();
  }

  Future<void> removeFromCollection(String collectionName, Word word) async {
    await _exploreService.removeFromCollection(collectionName, word);
    await initCollections();
  }

  Future<void> addCollection(String collectionName) async {
    await _exploreService.addCollection(collectionName);
    await initCollections();
  }

  Future<void> setCollections(Map<String, List<Word>> collections) async {
    await _exploreService.setCollections(collections);
    await initCollections();
  }

  @override
  Future<void> initService() async {
    _isHidden = true;
    _pageController = PageController();
    _exploreService = ExploreService();
    await _exploreService.initService();
    _isHidden = await _exploreService.getExploreHidden();
    initShouldShowScrollAnimation();
  }

  Future<void> hideExplore(bool value) async {
    _isHidden = value;
    notifyListeners();
    await _exploreService.setExploreHidden(value);
  }

  Future<void> showScrollAnimation() async {
    isAnimating = true;
    final list = List.generate(2, (index) => index).toList();
    final currentPosition = pageController.position.pixels - 100;
    await Future.forEach(list, (index) async {
      await pageController
          .animateTo(currentPosition + 300,
              duration: Duration(milliseconds: 2000), curve: Curves.fastOutSlowIn)
          .then((value) async {
        await Future.delayed(Duration(milliseconds: 1000));
      });
    });
    isAnimating = false;
    rememberLastScroll();
  }

  Future<void> rememberLastScroll() async {
    _scrollMessageShownDate = DateTime.now();
    _isScrollMessageShown = true;
    _shouldShowScrollAnimation = false;
    await _exploreService.setScrollMessageShownDate(_scrollMessageShownDate);
    await _exploreService.setIsScrollMessageShown(true);
    notifyListeners();
  }

  void toggleHiddenExplore() {
    _isHidden = !_isHidden;
    notifyListeners();
    _exploreService.setExploreHidden(_isHidden);
  }

  Future<List<Word>> getExploreWords(String email, {int page = 0}) async {
    // get All words
    _exploreWords = await _exploreService.getExploreWords(email);
    return _exploreWords;
  }

  @override
  Future<void> disposeService() async {
    _pageController.dispose();
  }
}
