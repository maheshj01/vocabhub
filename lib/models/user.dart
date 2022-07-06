import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/models/models.dart';
part 'user.g.dart';

@JsonSerializable()
class UserModel extends ChangeNotifier {
  String? idToken;
  String? accessToken;
  List<Word> bookmarks;
  String email;
  String name;
  String? avatarUrl;
  bool isLoggedIn;
  bool isAdmin;

  UserModel(
      {this.name = '',
      this.email = '',
      this.avatarUrl,
      this.idToken,
      this.isAdmin = false,
      this.accessToken,
      this.isLoggedIn = false,
      this.bookmarks = const []});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// todo: add created at parameter
  factory UserModel.copyWith(UserModel w) {
    return UserModel(
        name: w.name,
        email: w.email,
        avatarUrl: w.avatarUrl,
        idToken: w.idToken,
        accessToken: w.accessToken,
        isAdmin: w.isAdmin,
        isLoggedIn: w.isLoggedIn,
        bookmarks: w.bookmarks);
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
    bool? isAdmin,
    bool? isLoggedIn,
    List<Word>? bookmarks,
  }) {
    return UserModel(
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        idToken: idToken ?? this.idToken,
        accessToken: accessToken ?? this.accessToken,
        isAdmin: isAdmin ?? this.isAdmin,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        bookmarks: bookmarks ?? this.bookmarks);
  }

  factory UserModel.init() {
    return UserModel(
        name: '',
        email: '',
        avatarUrl: '',
        idToken: '',
        accessToken: '',
        bookmarks: [],
        isAdmin: false,
        isLoggedIn: false);

  }

  /// TODO: add a method to convert a User to JSON object
//  Map<String, dynamic> toJson() => {
//         'id': id,
//         'email': email,
//         'created_at': createdAt,
//         'last_sign_in_at': lastSignInAt,
//         'updated_at': updatedAt,
//       };

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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

  set user(UserModel? user) {
    if (user == null) {
      avatarUrl = null;
      accessToken = null;
      idToken = null;
      name = '';
      email = '';
      isLoggedIn = false;
    } else {
      avatarUrl = user.avatarUrl;
      accessToken = user.accessToken;
      idToken = user.idToken;
      name = user.name;
      email = user.email;
      isLoggedIn = true;
    }
    notifyListeners();
  }
}
