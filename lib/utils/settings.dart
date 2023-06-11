import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/word.dart';

class Settings extends ChangeNotifier {
  static final Settings _instance = Settings._internal();

  static Settings get instance => _instance;

  factory Settings() {
    return _instance;
  }

  Settings._internal();

  static SharedPreferences? _sharedPreferences;
  static const signedInKey = 'isSignedIn';
  static const emailKey = 'emailKey';
  static const skipCountKey = 'skipCount';
  static const recentKey = 'recent';
  static const maxSkipCount = 3;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static ThemeMode _theme = ThemeMode.light;

  static ThemeMode get theme => _theme;

  static set setSignedIn(bool value) {
    _sharedPreferences!.setBool('$signedInKey', value);
  }

  static FutureOr<String> get email async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    final _email = _sharedPreferences!.getString('$emailKey') ?? '';
    return _email;
  }

  static Future<void> setIsSignedIn(bool status, {String email = ''}) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    await _sharedPreferences!.setBool('$signedInKey', status);
    await _sharedPreferences!.setString('$emailKey', email);
    _instance.notify();
  }

  static set setSkipCount(int value) {
    _sharedPreferences!.setInt('$skipCountKey', value);
  }

  static void addRecent(Word word) async {
    final List<Word> recentList = await recents;
    if (!recentList.contains(word)) {
      recentList.add(word);
      final stringData = jsonEncode(recentList);
      await _sharedPreferences!.setString(recentKey, stringData);
    }
  }

  static Future<void> removeRecent(Word value) async {
    final List<Word> recentList = await recents;
    recentList.remove(value);
    final stringData = jsonEncode(recentList);
    await _sharedPreferences!.setString(recentKey, stringData);
  }

  static Future<List<Word>> get recents async {
    final recentList = _sharedPreferences!.getString('$recentKey') ?? '[]';
    final List<Word> recentWords = [];
    final words = jsonDecode(recentList);
    for (final word in words) {
      recentWords.add(Word.fromJson(word));
    }
    return recentWords;
  }

  static FutureOr<int> get skipCount async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    final int count = _sharedPreferences!.getInt('$skipCountKey') ?? 0;
    return count;
  }

  static Future<void> clear() async {
    await _sharedPreferences!.clear();
  }

  void notify() {
    notifyListeners();
  }
}
