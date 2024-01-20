import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel {
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
  bool deleted;
  DateTime? created_at;
  DateTime? updated_at;
  UserModel({
    this.idToken,
    this.accessToken,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.isLoggedIn = false,
    this.isAdmin = false,
    required this.username,
    this.token = '',
    this.deleted = false,
    this.created_at,
    this.updated_at,
  });

  UserModel copyWith({
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isLoggedIn,
    bool? isAdmin,
    String? username,
    String? token,
    bool? deleted,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return UserModel(
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isAdmin: isAdmin ?? this.isAdmin,
      username: username ?? this.username,
      token: token ?? this.token,
      deleted: deleted ?? this.deleted,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (idToken != null) {
      result.addAll({'idToken': idToken});
    }
    if (accessToken != null) {
      result.addAll({'accessToken': accessToken});
    }
    result.addAll({'email': email});
    result.addAll({'name': name});
    if (avatarUrl != null) {
      result.addAll({'avatarUrl': avatarUrl});
    }
    result.addAll({'isLoggedIn': isLoggedIn});
    result.addAll({'isAdmin': isAdmin});
    result.addAll({'username': username});
    result.addAll({'token': token});
    result.addAll({'deleted': deleted});
    if (created_at != null) {
      result.addAll({'created_at': created_at!.millisecondsSinceEpoch});
    }
    if (updated_at != null) {
      result.addAll({'updated_at': updated_at!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idToken: map['idToken'],
      accessToken: map['accessToken'],
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      isLoggedIn: map['isLoggedIn'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      username: map['username'] ?? '',
      token: map['token'] ?? '',
      deleted: map['deleted'] ?? false,
      created_at: map['created_at'].runtimeType == int
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.parse(map['created_at']),
      updated_at: map['updated_at'].runtimeType == int
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.parse(map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

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
        deleted: false,
        isLoggedIn: false);
  }

  @override
  String toString() {
    return 'UserModel(idToken: $idToken, accessToken: $accessToken, email: $email, name: $name, avatarUrl: $avatarUrl, isLoggedIn: $isLoggedIn, isAdmin: $isAdmin, username: $username, token: $token, deleted: $deleted, created_at: $created_at, updated_at: $updated_at)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.idToken == idToken &&
        other.accessToken == accessToken &&
        other.email == email &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.isLoggedIn == isLoggedIn &&
        other.isAdmin == isAdmin &&
        other.username == username &&
        other.token == token &&
        other.deleted == deleted &&
        other.created_at == created_at &&
        other.updated_at == updated_at;
  }

  @override
  int get hashCode {
    return idToken.hashCode ^
        accessToken.hashCode ^
        email.hashCode ^
        name.hashCode ^
        avatarUrl.hashCode ^
        isLoggedIn.hashCode ^
        isAdmin.hashCode ^
        username.hashCode ^
        token.hashCode ^
        deleted.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode;
  }
}
