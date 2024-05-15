import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/notifications/edit_expansion_tile.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NotificationDetail extends StatefulWidget {
  static const String route = '/notifications/detail';
  String word;
  String title;
  bool isNotification;

  NotificationDetail({
    Key? key,
    this.title = 'Edit Detail',
    this.isNotification = true,
    required this.word,
  }) : super(key: key);

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationDetailMobile(
              word: widget.word,
              title: widget.title,
              isNotification: widget.isNotification,
            ),
        mobileBuilder: (context) => NotificationDetailMobile(
              word: widget.word,
              title: widget.title,
              isNotification: widget.isNotification,
            ));
  }
}

class NotificationDetailDesktop extends StatelessWidget {
  const NotificationDetailDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NotificationDetailDesktop'),
      ),
    );
  }
}

class NotificationDetailMobile extends ConsumerStatefulWidget {
  String word;
  String title;
  bool isNotification;

  NotificationDetailMobile({
    Key? key,
    this.title = 'Edit Detail',
    this.isNotification = true,
    required this.word,
  }) : super(key: key);

  @override
  ConsumerState<NotificationDetailMobile> createState() => _NotificationDetailMobileState();
}

class _NotificationDetailMobileState extends ConsumerState<NotificationDetailMobile> {
  Future<void> getCurrentWord() async {
    currentWordNotifier.value = Response(
        state: RequestState.active,
        didSucced: false,
        message: 'Failed',
        status: 400,
        data: Word('', '', ''));
    PostgrestResponse<dynamic> resp;
    List<EditHistory> list;
    // if edit is pending
    // type: add -> show previous approved and current pending
    // type: edit -> show previous approved and current pending
    // type: delete -> show previous approved and current pending

    // if edit is rejected
    //
    // if edit is add then show current add
    // if edit is delete then show previous approved and current delete

    // find previous approved word
    resp = await EditHistoryService.findPreviousEditsByWord(widget.word,
        isNotification: widget.isNotification);
    // findById(widget.edit_history.word_id);
    if (resp.status == 200) {
      list = (resp.data as List).map((e) => EditHistory.fromJson(e)).toList();
      currentWordNotifier.value = currentWordNotifier.value.copyWith(
          state: RequestState.done, didSucced: true, message: 'Success', status: 200, data: list);
    } else {
      final lastApprovedEdit = Word('', '', '');
      currentWordNotifier.value = currentWordNotifier.value.copyWith(
          state: RequestState.error,
          didSucced: false,
          message: 'Failed',
          status: resp.status,
          data: lastApprovedEdit);
    }
  }

  Word getLastApprovedEdit(List<dynamic> list) {
    Word wordToCompare = Word('', '', '');

    for (int i = 0; i < list.length; i++) {
      final data = list[i];
      final history = EditHistory.fromJson(data);
      if (history.word.toLowerCase() == widget.word.toLowerCase() &&
          history.state == EditState.approved) {
        wordToCompare = Word.fromEditHistoryJson(data);
        // break;
      }
    }
    return wordToCompare;
  }

  Word getSecondLastApproved(List<dynamic> list) {
    Word wordToCompare = Word('', '', '');
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      final data = list[i];
      final history = EditHistory.fromJson(data);
      if (history.word.toLowerCase() == widget.word.toLowerCase() &&
          history.state == EditState.approved) {
        count += 1;
        if (count == 1) {
          wordToCompare = Word.fromEditHistoryJson(data);
          break;
        }
      }
    }
    return wordToCompare;
  }

  ValueNotifier<Response> currentWordNotifier = ValueNotifier<Response>(
      Response(didSucced: false, message: 'Failed', status: 400, data: Word('', '', '')));

  /// edit from database before the current edit

  @override
  void initState() {
    getCurrentWord();
    super.initState();
  }

  @override
  void dispose() {
    currentWordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(widget.isNotification ? 0.0 : 28.0)),
      child: Stack(
        children: [
          CustomPaint(
            painter: BackgroundPainter(
              primaryColor: colorScheme.primary,
              secondaryColor: colorScheme.inversePrimary,
              animation: Animation.fromValueListenable(
                AlwaysStoppedAnimation(0.1),
              ),
            ),
            child: Container(),
          ),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
          Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: false,
                title: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<Response>(
                        valueListenable: currentWordNotifier,
                        builder: (context, Response value, Widget? child) {
                          if (value.state == RequestState.active) {
                            return LoadingWidget();
                          }
                          final List<EditHistory> list = (value.data as List<EditHistory>);
                          return ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final EditHistory lastApprovedEdit;
                                final EditHistory currentEdit = list[index];
                                if (index == list.length - 1 || list.length == 1) {
                                  lastApprovedEdit = currentEdit;
                                } else {
                                  lastApprovedEdit = list[index + 1];
                                }
                                return EditExpansionDetail(currentEdit, lastApprovedEdit);
                              });
                        }),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class DifferenceVisualizer extends ConsumerWidget {
  const DifferenceVisualizer(
      {super.key, required this.newVersion, required this.oldVersion, required this.title});

  final String newVersion;
  final String oldVersion;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (oldVersion.isEmpty && newVersion.isEmpty) {
      return SizedBox.shrink();
    }

    final appThemeController = ref.watch(appThemeProvider);

    final bool hasChange = newVersion != oldVersion;
    if (!hasChange) {
      return ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          newVersion,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          newVersion.isEmpty
              ? SizedBox()
              : differenceVisualizerGranular(newVersion, oldVersion,
                  isOldVersion: false, isDark: appThemeController.isDark),
          oldVersion.isEmpty ? SizedBox.shrink() : 8.0.vSpacer(),
          oldVersion.isEmpty
              ? SizedBox.shrink()
              : differenceVisualizerGranular(newVersion, oldVersion,
                  isOldVersion: true, isDark: appThemeController.isDark),
        ],
      ),
    );
  }
}

/// Authenticate User using social auth
/// Allow users to post their ad
///
