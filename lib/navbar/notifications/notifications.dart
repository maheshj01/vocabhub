import 'package:flutter/material.dart';
import 'package:vocabhub/constants/styles.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/widgets.dart';

class Notifications extends StatefulWidget {
  static const String route = '/notifications';
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = AppStateScope.of(context).user!;
      getNotifications();
    });
  }

  Future<void> getNotifications() async {
    final resp = await EditHistoryService.getUserEdits(user!);
    if (resp.didSucced && resp.data != null) {
      final data = resp.data as List<NotificationModel>;
      // data.sort((a, b) => b.edit.created_at!.compareTo(a.edit.created_at!));
      historyNotifier.value = data;
    } else {
      showMessage(context, 'failed to get notifications');
    }
  }

  Future<void> updateRequest(String editId, EditState state) async {
    showCircularIndicator(context);
    final resp = await EditHistoryService.updateRequest(editId, state: state);
    if (resp.didSucced) {
      getNotifications();
    } else {
      showMessage(
        context,
        'Failed to cancel request',
      );
    }
    _stopLoading();
  }

  void _stopLoading() {
    Navigate().popView(context);
  }

  ValueNotifier<List<NotificationModel>?> historyNotifier =
      ValueNotifier<List<NotificationModel>?>(null);

  UserModel? user;

  @override
  void dispose() {
    historyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Notifications',
          ),
        ),
        body: ValueListenableBuilder<List<NotificationModel>?>(
            valueListenable: historyNotifier,
            builder: (BuildContext context, List<NotificationModel>? value,
                Widget? child) {
              if (value == null || user == null) {
                return LoadingWidget();
              }
              // TODO: Toggle isAdmin
              if (user!.isAdmin) {
                return ListView.builder(
                    padding:
                        EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                    itemBuilder: (context, index) {
                      final edit = value[index].edit;
                      final editor = value[index].user;
                      return !user!.isAdmin
                          ? UserNotificationTile(
                              edit: edit,
                              user: editor,
                              onCancel: () {
                                updateRequest(
                                    edit.edit_id!, EditState.cancelled);
                                print('request has been cancelled');
                              },
                            )
                          : AdminNotificationTile(
                              edit: edit,
                              user: editor,
                              onAction: (approved) {
                                if (approved) {
                                  updateRequest(
                                      edit.edit_id!, EditState.approved);
                                  print('request has been approved');
                                } else {
                                  updateRequest(
                                      edit.edit_id!, EditState.rejected);
                                  print('request has been rejected');
                                }
                              },
                              onTap: () {
                                print('admin tapped');
                              },
                            );
                    },
                    itemCount: value.length);
              }
              return ListView.builder(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  itemBuilder: (context, index) {
                    final edit = value[index].edit;
                    final editUser = value[index].user;
                    return UserNotificationTile(
                      edit: edit,
                      user: editUser,
                      onCancel: () async {
                        updateRequest(edit.edit_id!, EditState.cancelled);
                        print('request has been cancelled');
                      },
                    );
                  },
                  itemCount: value.length);
            }));
  }
}

class UserNotificationTile extends StatelessWidget {
  final EditHistory edit;
  final UserModel user;
  final Function? onCancel;

  const UserNotificationTile(
      {Key? key, required this.edit, required this.user, this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = stateToIconColor(edit.state!);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: stateToNotificationCardColor(edit.state!),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [VocabTheme.notificationCardShadow],
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            VHIcon(
              stateToNotificationIconData(edit.state!),
              size: 58,
              iconColor: iconColor,
              border: Border.all(color: iconColor, width: 2),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: buildNotification(
                        editTypeToUserNotification(edit, user),
                        edit.word,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(edit.created_at!.formatDate(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                        edit.state == EditState.pending
                            ? VocabButton(
                                onTap: () {
                                  onCancel!();
                                },
                                label: 'Cancel',
                                width: 100,
                                height: 30,
                                fontSize: 16,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminNotificationTile extends StatelessWidget {
  final Function(bool) onAction;
  final Function? onTap;
  final EditHistory edit;
  final UserModel user;
  const AdminNotificationTile(
      {super.key,
      required this.edit,
      required this.onAction,
      required this.user,
      this.onTap});

  Widget circle({Color color = Colors.red, double size = 16}) {
    return Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  @override
  Widget build(BuildContext context) {
    /// Approve or reject card
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [VocabTheme.notificationCardShadow],
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircularAvatar(
              url: user.avatarUrl,
              name: user.name,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      child: buildNotification(
                        editTypeToAdminNotification(edit, user),
                        edit.word,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(edit.created_at!.formatDate(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                        Container(
                          width: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              circle(
                                  color: stateToIconColor(edit.state!),
                                  size: 12),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                edit.state!.toName().capitalize()!,
                              )
                            ],
                          ),
                        ),
                        if (edit.state == EditState.pending)
                          Row(
                            children: [
                              VHIcon(Icons.close,
                                  size: 36,
                                  backgroundColor: Colors.white,
                                  border:
                                      Border.all(color: Colors.red, width: 2),
                                  iconColor: Colors.red, onTap: () {
                                onAction(false);
                              }),
                              SizedBox(
                                width: 16,
                              ),
                              VHIcon(Icons.check,
                                  size: 36,
                                  backgroundColor: Colors.white,
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  iconColor: Colors.green, onTap: () {
                                onAction(true);
                              }),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
