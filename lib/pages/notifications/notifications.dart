import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/navbar/profile/profile.dart';
import 'package:vocabhub/pages/notifications/NotificationEditDetail.dart';
import 'package:vocabhub/pages/notifications/notification_detail.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NotificationsNavigator extends StatefulWidget {
  final String word;
  final bool? isNotification;
  final String title;
  const NotificationsNavigator(
      {super.key, required this.word, this.isNotification = true, this.title = 'Edit Detail'});

  @override
  State<NotificationsNavigator> createState() => _NotificationsNavigatorState();
}

class _NotificationsNavigatorState extends State<NotificationsNavigator> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      child: Navigator(
        initialRoute: Notifications.route,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Notifications.route:
              return MaterialPageRoute(builder: (context) => Notifications());
            case NotificationDetail.route:
              // final collection = settings.arguments as VHCollection;
              return MaterialPageRoute(
                  builder: (context) => NotificationDetail(
                      isNotification: widget.isNotification!,
                      word: widget.word,
                      title: widget.title));
            default:
              return MaterialPageRoute(
                  builder: (context) => ErrorPage(
                      onRetry: () {},
                      errorMessage: 'Oh no! You have landed on an unknown planet '));
          }
        },
      ),
    );
  }
}

class Notifications extends StatefulWidget {
  static const String route = '/notifications';
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationsMobile(),
        mobileBuilder: (context) => NotificationsMobile());
  }
}

class NotificationsMobile extends ConsumerStatefulWidget {
  const NotificationsMobile({Key? key}) : super(key: key);

  @override
  _NotificationsMobileState createState() => _NotificationsMobileState();
}

class _NotificationsMobileState extends ConsumerState<NotificationsMobile> {
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = ref.read(userNotifierProvider);
      getNotifications();
    });
  }

  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  final List<NotificationModel> _items = [];
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  /// Refresh: reload from the first page.
  Future<void> getNotifications() => _loadPage(reset: true);

  Future<void> _loadPage({bool reset = false}) async {
    if (user == null) return;
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    final resp = await EditHistoryService.getUserEdits(user!, limit: _pageSize, offset: _offset);
    if (!mounted) return;
    if (resp.didSucced && resp.data != null) {
      final data = resp.data as List<NotificationModel>;
      if (reset) _items.clear();
      _items.addAll(data);
      _offset += data.length;
      _hasMore = data.length == _pageSize;
      historyNotifier.value = List<NotificationModel>.of(_items);
    } else if (reset) {
      NavbarNotifier.showSnackBar(context, 'failed to get notifications');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _loadPage();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (_hasMore && !_isLoadingMore && position.pixels >= position.maxScrollExtent - 320) {
      _loadMore();
    }
  }

  Future<void> updateGlobalDatabase(EditHistory edit, EditState state, UserModel editor) async {
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
        pushNotificationService.sendNotificationToTopic(PushNotificationService.newWordTopic,
            'New Word: ${word.word}', 'A new word has been added to Vocabhub');
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
      await updateEditRequest(edit, state, editor);
    } else {
      NavbarNotifier.showSnackBar(
        context,
        'Failed to complete the request, Please try again!',
      );
    }
  }

  Future<void> updateEditRequest(EditHistory edit, EditState state, UserModel user) async {
    showCircularIndicator(context);
    final resp = await EditHistoryService.updateRequest(edit.edit_id!, state: state);
    if (resp.didSucced) {
      getNotifications();
      final token = user.token;
      pushNotificationService.sendNotification(
        Constants.constructEditStatusChangePayload("$token", edit, state),
      );
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
    _scrollController.dispose();
    historyNotifier.dispose();
    super.dispose();
  }

  Widget _emptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: colorScheme.outline),
          12.0.vSpacer(),
          Text('No notifications yet',
              style:
                  Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
          6.0.vSpacer(),
          Padding(
            padding: 32.0.horizontalPadding,
            child: Text(
              'Your edit requests and their updates will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> notificationsKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final userRef = ref.watch(userNotifierProvider);
    return Material(
      color: Colors.transparent,
      key: notificationsKey,
      child: Column(
        children: [
          AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            title: Text(
              'Notifications',
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<NotificationModel>?>(
                valueListenable: historyNotifier,
                builder: (BuildContext context, List<NotificationModel>? value, Widget? child) {
                  if (value == null || user == null) {
                    return LoadingWidget();
                  }
                  if (value.isEmpty || !userRef.isLoggedIn) {
                    return _emptyState(context);
                  }
                  return RefreshIndicator(
                    onRefresh: getNotifications,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: kBottomNavigationBarHeight),
                      itemCount: value.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Load-more footer while further pages remain.
                        if (index >= value.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final edit = value[index].edit;
                        final editor = value[index].user;
                        if (user!.isAdmin) {
                          return AdminNotificationTile(
                            edit: edit,
                            user: editor,
                            onAvatarTap: () {
                              Navigate.push(
                                  context,
                                  Scaffold(
                                      appBar: AppBar(
                                        elevation: 0,
                                        centerTitle: false,
                                        title: Text('Profile'),
                                      ),
                                      body: UserProfile(email: editor.email, isReadOnly: true)));
                            },
                            onAction: (approved) async {
                              if (approved) {
                                updateGlobalDatabase(edit, EditState.approved, editor);
                              } else {
                                updateEditRequest(edit, EditState.rejected, editor);
                              }
                            },
                            onTap: () {
                              Navigate.push(
                                  context,
                                  NotificationDetail(
                                    word: edit.word,
                                    title: 'Edit History',
                                    isNotification: true,
                                  ));
                            },
                          );
                        }
                        return UserNotificationTile(
                          edit: edit,
                          user: editor,
                          onTap: () {
                            Navigate.push(
                                context,
                                NotificationEditDetailResponsive(
                                  word: edit.word,
                                  title: 'Edit Detail',
                                  isNotification: true,
                                ),
                                isRootNavigator: false);
                          },
                          onCancel: () async {
                            updateEditRequest(edit, EditState.cancelled, editor);
                          },
                        );
                      },
                    ),
                  );
                }),
          ),
        ],
      ),
    );
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
    return _NotificationCard(
      onTap: () => onTap?.call(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VHIcon(
            stateToNotificationIconData(edit.state!),
            size: 46,
            iconColor: iconColor,
            border: Border.all(color: iconColor, width: 2),
            backgroundColor: Colors.transparent,
          ),
          12.0.hSpacer(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildNotification(
                  editTypeToUserNotification(edit, user),
                  edit.word,
                  style: TextStyle(
                      color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                10.0.vSpacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(edit.created_at!.formatDate(),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    if (edit.state == EditState.pending)
                      VHButton(
                        onTap: () => onCancel!(),
                        label: 'Cancel',
                        width: 92,
                        height: 34,
                        fontSize: 14,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      )
                    else
                      _StatusChip(state: edit.state!),
                  ],
                ),
              ],
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
  final UserModel user;
  final Function() onAvatarTap;

  const AdminNotificationTile({
    super.key,
    required this.edit,
    required this.onAction,
    required this.user,
    required this.onAvatarTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// Approve or reject card
    final colorScheme = Theme.of(context).colorScheme;
    return _NotificationCard(
      onTap: () => onTap?.call(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularAvatar(url: user.avatarUrl, name: user.name, onTap: onAvatarTap),
              12.0.hSpacer(),
              Expanded(
                child: buildNotification(
                  editTypeToAdminNotification(edit, user),
                  edit.word,
                  style: TextStyle(
                      color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          12.0.vSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _StatusChip(state: edit.state!),
                    10.0.hSpacer(),
                    Flexible(
                      child: Text(
                        edit.created_at!.formatDate(),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (edit.state == EditState.pending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VHIcon(Icons.close,
                        size: 36,
                        backgroundColor: Colors.transparent,
                        border: Border.all(color: Colors.red, width: 2),
                        iconColor: Colors.red,
                        onTap: () => onAction(false)),
                    12.0.hSpacer(),
                    VHIcon(Icons.check,
                        size: 36,
                        backgroundColor: Colors.transparent,
                        border: Border.all(color: Colors.green, width: 2),
                        iconColor: Colors.green,
                        onTap: () => onAction(true)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rounded, tappable card shell shared by the notification tiles. Also caps the
/// width and centers on large screens, so the list reads well full-screen and
/// inside the desktop dashboard panel alike.
class _NotificationCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _NotificationCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(padding: const EdgeInsets.all(14), child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill showing an edit's state with a coloured dot.
class _StatusChip extends StatelessWidget {
  final EditState state;
  const _StatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = stateToIconColor(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle(color: color, size: 8),
          6.0.hSpacer(),
          Text(
            state.toName().capitalize()!,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
