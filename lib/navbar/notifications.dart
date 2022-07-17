import 'package:flutter/material.dart';
import 'package:vocabhub/constants/styles.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utility.dart';
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = AppStateScope.of(context).user!;
      getNotifications();
    });
  }

  Future<void> getNotifications() async {
    final resp = await EditHistoryService.getUserEdits(user!);
    if (resp.didSucced && resp.data != null) {
      historyNotifier.value = resp.data as List<NotificationModel>;
    } else {}
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

              if (user!.isAdmin) {
                return ListView.builder(
                    padding:
                        EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                    itemBuilder: (context, index) {
                      final edit = value[index].edit;
                      final user = value[index].user;
                      return AdminNotificationTile(
                        edit: edit,
                        onAction: (approved) {
                          if (approved) {
                          } else {}
                        },
                        onTap: () {},
                      );
                    },
                    itemCount: value.length);
              }
              return ListView.builder(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  itemBuilder: (context, index) {
                    final edit = value[index].edit;
                    final user = value[index].user;
                    return Container(
                      height: 85,
                      decoration: BoxDecoration(
                        color: stateToNotificationCardColor(edit.state!),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              spreadRadius: 0,
                              offset: Offset(0, 4))
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: UserNotificationTile(
                        edit: edit,
                        user: user,
                      ),
                    );
                  },
                  itemCount: value.length);
            }));
  }
}

class UserNotificationTile extends StatelessWidget {
  final EditHistory edit;
  final UserModel user;
  const UserNotificationTile({Key? key, required this.edit, required this.user})
      : super(key: key);
  RichText buildNotification(String notification, String word,
      {TextStyle? style}) {
    final List<InlineSpan>? textSpans = [];
    final iterable = notification.split(' ').toList().map((e) {
      final isMatched = e.toLowerCase().contains(word.toLowerCase());
      return TextSpan(
          text: e + ' ',
          style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: isMatched ? FontWeight.bold : FontWeight.w500));
    }).toList();
    textSpans!.addAll(iterable);
    return RichText(text: TextSpan(text: '', children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = stateToIconColor(edit.state!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildNotification(
                    editTypeToNotification(edit),
                    edit.word,
                  ),
                  Row(
                    children: [
                      Text(
                        edit.word,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminNotificationTile extends StatelessWidget {
  final Function(bool) onAction;
  final Function? onTap;
  final EditHistory edit;
  const AdminNotificationTile(
      {super.key, required this.edit, required this.onAction, this.onTap});

  @override
  Widget build(BuildContext context) {
    /// Approve or reject card
    return Card(
      child: ListTile(
        title: Text('Word'),
        subtitle: Text('Meaning'),
        trailing: Text('State'),
      ),
    );
  }
}
