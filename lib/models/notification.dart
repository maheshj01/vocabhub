import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/user.dart';

part '../generated/models/notification.g.dart';

/// [createFactory] is off on purpose: the JSON here is a flat `edit_history`
/// row (not a `{user, edit}` shape), so the default generated factory is wrong.
/// The factory below is hand-written and safe to regenerate around.
@JsonSerializable(createFactory: false)
class NotificationModel {
  final UserModel user;
  final EditHistory edit;

  NotificationModel(this.user, this.edit);

  /// Each row is a flat `edit_history` record. When the query joins the author
  /// profile it arrives nested under the `users_mobile` key; otherwise we fall
  /// back to the row itself ([UserModel.fromJson] is null-tolerant). The edit
  /// is always the whole row.
  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        UserModel.fromJson((json[Constants.USER_TABLE_NAME] as Map<String, dynamic>?) ?? json),
        EditHistory.fromJson(json),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          edit == other.edit &&
          user == other.user;

  @override
  int get hashCode => user.email.hashCode ^ edit.edit_id.hashCode;

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
