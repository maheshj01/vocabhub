import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:supabase/supabase.dart';
import 'package:vocabhub/models/word_model.dart';
part 'user.g.dart';

@JsonSerializable()
class User extends ChangeNotifier {
  String? idToken;
  String? accessToken;
  List<Word> bookmarks;
  String email;
  String name;
  String? avatarUrl;
  bool isLoggedIn;

  User(
      {this.name = '',
      this.email = '',
      this.avatarUrl,
      this.idToken,
      this.accessToken,
      this.isLoggedIn = false,
      this.bookmarks = const []});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.copyWith(User w) {
    return User(
        name: w.name,
        email: w.email,
        avatarUrl: w.avatarUrl,
        idToken: w.idToken,
        accessToken: w.accessToken,
        bookmarks: w.bookmarks);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  set setEmail(String m) {
    email = m;
    notifyListeners();
  }

  set setName(String m) {
    name = m;
    notifyListeners();
  }

  set setIdToken(String m) {
    idToken = m;
    notifyListeners();
  }

  set setAccessToken(String m) {
    accessToken = m;
    notifyListeners();
  }

  set setAvatarUrl(String m) {
    avatarUrl = m;
    notifyListeners();
  }

  set user(User user) {
    avatarUrl = user.avatarUrl;
    accessToken = user.accessToken;
    idToken = user.idToken;
    name = user.name;
    email = user.email;
    isLoggedIn = true;
    notifyListeners();
  }
}
