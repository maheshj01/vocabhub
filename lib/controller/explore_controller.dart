import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/explore_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class ExploreController extends ChangeNotifier implements ServiceBase {
  late DateTime _scrollMessageShownDate;
  late bool _isScrollMessageShown = false;
  late final ExploreService _exploreService;
  List<Word> _exploreWords = [];

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

  // simulate scroll up with page up/down animation
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

  /// remember the last scroll date
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

@immutable
class AutoScroll {
  final bool enabled;
  final int durationInSeconds;
  final bool isPaused;

  AutoScroll({
    this.enabled = true,
    this.durationInSeconds = 30,
    this.isPaused = false
  });

  AutoScroll copyWith({
    bool? enabled,
    int? durationInSeconds,
    bool? isPaused,
  }) {
    return AutoScroll(
      enabled: enabled ?? this.enabled,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'enabled': enabled});
    result.addAll({'durationInSeconds': durationInSeconds});
    result.addAll({'isPaused': isPaused});
  
    return result;
  }

  factory AutoScroll.fromMap(Map<String, dynamic> map) {
    return AutoScroll(
      enabled: map['enabled'] ?? false,
      durationInSeconds: map['durationInSeconds']?.toInt() ?? 0,
      isPaused: map['isPaused'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoScroll.fromJson(String source) => AutoScroll.fromMap(json.decode(source));

  @override
  String toString() => 'AutoScroll(enabled: $enabled, durationInSeconds: $durationInSeconds, isPaused: $isPaused)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AutoScroll &&
      other.enabled == enabled &&
      other.durationInSeconds == durationInSeconds &&
      other.isPaused == isPaused;
  }

  @override
  int get hashCode => enabled.hashCode ^ durationInSeconds.hashCode ^ isPaused.hashCode;
}
