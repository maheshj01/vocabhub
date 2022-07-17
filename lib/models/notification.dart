import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/user.dart';
part 'notification.g.dart';

/// warning: do not regenerate model for this file
class NotificationModel {
  final UserModel user;
  final EditHistory edit;

  NotificationModel(this.user, this.edit);

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

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
