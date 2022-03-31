import 'package:flutter/material.dart';

class MenuItem {
  const MenuItem(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

class NavbarNotifier extends ChangeNotifier {
  int _index = 0;
  int _last = 0;
  bool _shouldReload = false;
  bool _hideBottomNavBar = false;
  int _categoryIndex = 0;
  List<int> _indexList = [];

  /// while toggling the tabs programatically
  /// update [shouldReload] to whether or not to fetch the updated Data from the network
  bool get shouldReload => _shouldReload;

  void remove() {
    _indexList.removeLast();
    notifyListeners();
  }

  void add(int x) {
    _indexList.add(x);
    notifyListeners();
  }

  int get top => _indexList.last;

  int get length => _indexList.length;

  int get index => _index;

  set index(int x) {
    _index = x;
    notifyListeners();
  }

  int get categoryIndex => _categoryIndex;
  set categoryIndex(int x) {
    _categoryIndex = x;
    notifyListeners();
  }

  set shouldReload(bool x) {
    _shouldReload = x;
    notifyListeners();
  }

  bool get hideBottomNavBar => _hideBottomNavBar;

  set hideBottomNavBar(bool x) {
    _hideBottomNavBar = x;
    notifyListeners();
  }
}
