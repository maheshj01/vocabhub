import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel extends ChangeNotifier {
  String? idToken;
  String? accessToken;
  String email;
  String name;
  String? avatarUrl;
  bool isLoggedIn;
  bool isAdmin;
  String username;
  // push notification token
  String token;
  bool isDeleted;
  DateTime? created_at;
  DateTime? updated_at;

  UserModel({
    this.name = '',
    this.email = '',
    this.avatarUrl,
    this.idToken,
    this.isAdmin = false,
    this.accessToken,
    this.token = '',
    this.username = '',
    this.created_at,
    this.updated_at,
    this.isDeleted = false,
    this.isLoggedIn = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// todo: add created at parameter
  factory UserModel.copyWith(UserModel w) {
    return UserModel(
      name: w.name,
      email: w.email,
      avatarUrl: w.avatarUrl,
      idToken: w.idToken,
      accessToken: w.accessToken,
      isAdmin: w.isAdmin,
      username: w.username,
      token: w.token,
      isDeleted: w.isDeleted,
      created_at: w.created_at,
      updated_at: w.updated_at,
      isLoggedIn: w.isLoggedIn,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
    bool? isAdmin,
    bool? isLoggedIn,
    String? username,
    String? token,
    DateTime? created_at,
    DateTime? updated_at,
    bool? isDeleted,
    List<Word>? bookmarks,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      isAdmin: isAdmin ?? this.isAdmin,
      username: username ?? this.username,
      token: token ?? this.token,
      isDeleted: isDeleted ?? this.isDeleted,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  factory UserModel.init() {
    return UserModel(
        name: '',
        email: '',
        avatarUrl: '',
        idToken: '',
        accessToken: '',
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
        username: '',
        token: '',
        isAdmin: false,
        isDeleted: false,
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

  set loggedIn(bool m) {
    isLoggedIn = m;
    notifyListeners();
  }

  set setIsDeleted(bool m) {
    isDeleted = m;
    notifyListeners();
  }

  UserModel get user => this;

  // updates local state and also stores in local storage
  setUser(UserModel user) {
    this.name = user.name;
    this.email = user.email;
    this.avatarUrl = user.avatarUrl;
    this.idToken = user.idToken;
    this.accessToken = user.accessToken;
    this.isAdmin = user.isAdmin;
    this.username = user.username;
    this.token = user.token;
    this.created_at = user.created_at;
    this.isLoggedIn = user.isLoggedIn;
    this.isDeleted = user.isDeleted;
    authController.setUser(this);
    notifyListeners();
  }
}
