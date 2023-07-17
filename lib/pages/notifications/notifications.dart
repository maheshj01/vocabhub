import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/navbar/profile/profile.dart';
import 'package:vocabhub/pages/notifications/notification_detail.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/widgets.dart';

class Notifications extends ConsumerStatefulWidget {
  static const String route = '/notifications';
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<Notifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = ref.watch(userNotifierProvider);
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
      NavbarNotifier.showSnackBar(context, 'failed to get notifications');
    }
  }

  Future<void> updateGlobalDatabase(EditHistory edit, EditState state) async {
    showCircularIndicator(context);
    bool isSuccess = false;
    final Word word = Word(
      edit.word_id,
      edit.word,
      edit.meaning,
      examples: edit.examples,
      synonyms: edit.synonyms,
      created_at: DateTime.now().toUtc(),
    );
    if (edit.edit_type == EditType.add) {
      final resp = await VocabStoreService.addWord(word);
      stopCircularIndicator(context);
      if (resp.didSucced) {
        NavbarNotifier.showSnackBar(context, 'Word added successfully!');
        isSuccess = true;
      } else {
        NavbarNotifier.showSnackBar(context, 'Failed to add word, Please try again!');
        return;
      }
    } else if (edit.edit_type == EditType.edit) {
      final resp = await VocabStoreService.updateWord(id: edit.word_id, word: word);
      stopCircularIndicator(context);
      if (resp.status == 200) {
        NavbarNotifier.showSnackBar(context, 'Word updated successfully');
        isSuccess = true;
      } else {
        NavbarNotifier.showSnackBar(context, 'Failed to update word, please try again');
        return;
      }
    } else if (edit.edit_type == EditType.delete) {
      final resp = await VocabStoreService.deleteById(edit.word_id);
      stopCircularIndicator(context);
      if (resp.status == 200) {
        NavbarNotifier.showSnackBar(context, 'Word deleted successfully');
        isSuccess = true;
      } else {
        NavbarNotifier.showSnackBar(context, 'Failed to delete word, please try again');
        return;
      }
    }
    if (isSuccess) {
      await updateRequest(edit, state);
    } else {
      NavbarNotifier.showSnackBar(
        context,
        'Failed to complete the request, Please try again!',
      );
    }
  }

  Future<void> updateRequest(EditHistory edit, EditState state) async {
    showCircularIndicator(context);
    final resp = await EditHistoryService.updateRequest(edit.edit_id!, state: state);
    if (resp.didSucced) {
      getNotifications();
    } else {
      NavbarNotifier.showSnackBar(
        context,
        'Something went wrong, please try again',
      );
    }
    stopCircularIndicator(context);
  }

  ValueNotifier<List<NotificationModel>?> historyNotifier =
      ValueNotifier<List<NotificationModel>?>(null);

  UserModel? user;

  @override
  void dispose() {
    historyNotifier.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> notificationsKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        backgroundColor: colorScheme.surface,
        key: notificationsKey,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Notifications',
          ),
        ),
        body: ValueListenableBuilder<List<NotificationModel>?>(
            valueListenable: historyNotifier,
            builder: (BuildContext context, List<NotificationModel>? value, Widget? child) {
              if (value == null || user == null) {
                return LoadingWidget();
              }
              if (value.isEmpty) {
                return Center(
                  child: Text('No notifications'),
                );
              }
              if (user!.isAdmin) {
                return ListView.builder(
                    padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                    itemBuilder: (context, index) {
                      final edit = value[index].edit;
                      final editor = value[index].user;
                      return !user!.isAdmin
                          ? UserNotificationTile(
                              edit: edit,
                              user: editor,
                              onTap: () {},
                              onCancel: () {
                                updateRequest(edit, EditState.cancelled);
                              },
                            )
                          : AdminNotificationTile(
                              edit: edit,
                              user: editor,
                              onAvatarTap: () {
                                Navigate.push(
                                    context,
                                    Scaffold(
                                        appBar: AppBar(
                                          elevation: 0,
                                          centerTitle: false,
                                          title: Text(
                                            'Profile',
                                          ),
                                        ),
                                        body: UserProfile(
                                          email: editor.email,
                                          isReadOnly: true,
                                        )));
                              },
                              onAction: (approved) async {
                                if (approved) {
                                  updateGlobalDatabase(edit, EditState.approved);
                                } else {
                                  updateRequest(edit, EditState.rejected);
                                }
                              },
                              onTap: () {
                                Navigate.push(
                                    context,
                                    NotificationDetail(
                                      editHistory: edit,
                                    ));
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
                      onTap: () {
                        Navigate.push(
                            context,
                            NotificationDetail(
                              editHistory: edit,
                            ));
                      },
                      onCancel: () async {
                        updateRequest(edit, EditState.cancelled);
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
  final Function? onTap;

  const UserNotificationTile(
      {Key? key, required this.edit, required this.user, this.onTap, this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = stateToIconColor(edit.state!);
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
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
              8.0.hSpacer(),
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
                                  .titleSmall!
                                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                          edit.state == EditState.pending
                              ? VHButton(
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
      ),
    );
  }
}

class AdminNotificationTile extends StatelessWidget {
  final Function(bool) onAction;
  final Function? onTap;
  final EditHistory edit;
  final UserModel user;
  final Function onAvatarTap;

  const AdminNotificationTile({
    super.key,
    required this.edit,
    required this.onAction,
    required this.user,
    required this.onAvatarTap,
    this.onTap,
  });

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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
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
              onTap: () {
                onAvatarTap();
              },
            ),
            8.0.hSpacer(),
            Expanded(
              child: InkWell(
                onTap: () {
                  onTap?.call();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        child: buildNotification(editTypeToAdminNotification(edit, user), edit.word,
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    circle(color: stateToIconColor(edit.state!), size: 12),
                                    6.0.hSpacer(),
                                    Text(
                                      edit.state!.toName().capitalize()!,
                                    )
                                  ],
                                ),
                              ),
                              4.0.vSpacer(),
                              Text(edit.created_at!.formatDate(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (edit.state == EditState.pending)
                            Row(
                              children: [
                                VHIcon(Icons.close,
                                    size: 36,
                                    backgroundColor: Colors.white,
                                    border: Border.all(color: Colors.red, width: 2),
                                    iconColor: Colors.red, onTap: () {
                                  onAction(false);
                                }),
                                16.0.hSpacer(),
                                VHIcon(Icons.check,
                                    size: 36,
                                    backgroundColor: Colors.white,
                                    border: Border.all(color: Colors.green, width: 2),
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
            ),
          ],
        ),
      ),
    );
  }
}
