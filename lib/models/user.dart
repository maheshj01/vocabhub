import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/constants/const.dart';

part 'user.g.dart';

/// Immutable profile model for a Vocabhub user.
///
/// Identity is anchored on [uid] (the Firebase Auth uid), which is stable across
/// both Google and phone sign-in. [email] is empty for phone-only users and
/// [phone] is null for Google-only users.
///
/// This is a pure data object — it holds no behaviour and notifies nothing.
/// Session state is owned by the auth notifier (`authProvider`); UI reads the
/// current user via `currentUserProvider`.
@JsonSerializable()
class UserModel {
  /// Firebase Auth uid — the canonical identity key.
  final String uid;

  /// Email address. Empty string when unknown (e.g. phone-auth users).
  final String email;

  /// E.164 phone number. Null for users who signed in with Google only.
  final String? phone;

  final String name;
  final String? avatarUrl;
  final bool isLoggedIn;
  final bool isAdmin;
  final String username;

  /// FCM push-notification token.
  final String token;

  @JsonKey(name: Constants.DELETED_COLUMN)
  final bool isDeleted;

  final DateTime? created_at;
  final DateTime? updated_at;

  const UserModel({
    this.uid = '',
    this.email = '',
    this.phone,
    this.name = '',
    this.avatarUrl,
    this.isAdmin = false,
    this.token = '',
    this.username = '',
    this.created_at,
    this.updated_at,
    this.isDeleted = false,
    this.isLoggedIn = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// An empty, signed-out user.
  factory UserModel.init() => const UserModel();

  /// True when this instance represents a real, resolved account.
  bool get isEmpty => uid.isEmpty && email.isEmpty && (phone == null || phone!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  UserModel copyWith({
    String? uid,
    String? email,
    String? phone,
    String? name,
    String? avatarUrl,
    bool? isAdmin,
    bool? isLoggedIn,
    String? username,
    String? token,
    DateTime? created_at,
    DateTime? updated_at,
    bool? isDeleted,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      username: username ?? this.username,
      token: token ?? this.token,
      isDeleted: isDeleted ?? this.isDeleted,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
