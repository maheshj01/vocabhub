import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';

class Settings {
  static SharedPreferences? _sharedPreferences;
  static const signedInKey = 'isSignedIn';
  static const emailKey = 'emailKey';
  static const skipCountKey = 'skipCount';
  static const darkKey = 'isDark';
  static const maxSkipCount = 3;
  static Size size = Size.zero;

  Settings() {
    init();
  }

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  set dark(bool value) {
    _sharedPreferences!.setBool('isDark', value);
  }

  Future<bool> get isDark async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    bool _dark = _sharedPreferences!.getBool('isDark') ?? false;
    if (_dark) {
      darkNotifier.value = true;
    }
    return _dark;
  }

  set setSignedIn(bool value) {
    _sharedPreferences!.setBool('$signedInKey', value);
  }

  FutureOr<bool> get isSignedIn async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    final _isSignedIn = _sharedPreferences!.getBool('$signedInKey') ?? false;
    return _isSignedIn;
  }

  FutureOr<String> get email async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    final _email = _sharedPreferences!.getString('$emailKey') ?? '';
    return _email;
  }

  Future<void> setIsSignedIn(bool status, {String email = ''}) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    await _sharedPreferences!.setBool('$signedInKey', status);
    await _sharedPreferences!.setString('$emailKey', email);
  }

  set setSkipCount(int value) {
    _sharedPreferences!.setInt('$skipCountKey', value);
  }

  FutureOr<int> get skipCount async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    final int count = _sharedPreferences!.getInt('$skipCountKey') ?? 0;
    return count;
  }
}
