import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final String? idToken;
  final String? accessToken;
  String email;
  String name;
  String? avatarUrl;

  User(this.name, this.email, this.avatarUrl, {this.idToken, this.accessToken});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.copyWith(User w) {
    return User(w.name, w.email, w.avatarUrl,
        idToken: w.idToken, accessToken: w.accessToken);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
