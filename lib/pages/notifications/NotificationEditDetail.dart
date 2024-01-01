import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/notifications/notification_detail.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NotificationEditDetailResponsive extends StatelessWidget {
  static const String route = '/notifications/edit/detail';
  final String word;
  final String title;
  final bool isNotification;
  NotificationEditDetailResponsive({
    Key? key,
    this.title = 'Edit Detail',
    this.isNotification = true,
    required this.word,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationEditDetail(
              word: word,
              title: title,
              isNotification: isNotification,
            ),
        mobileBuilder: (context) => NotificationEditDetail(
              word: word,
              title: title,
              isNotification: isNotification,
            ));
  }
}

class NotificationEditDetail extends StatefulWidget {
  final String word;
  final String title;
  final bool isNotification;
  NotificationEditDetail({
    Key? key,
    this.title = 'Edit Detail',
    this.isNotification = true,
    required this.word,
  }) : super(key: key);

  @override
  State<NotificationEditDetail> createState() => _NotificationEditDetailState();
}

class _NotificationEditDetailState extends State<NotificationEditDetail> {
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
      currentEdit = list[0];
      if (list.length == 1) {
        lastApprovedEdit = currentEdit;
      } else {
        lastApprovedEdit = list[1];
      }
      currentWordNotifier.value = currentWordNotifier.value.copyWith(
          state: RequestState.done, didSucced: true, message: 'Success', status: 200, data: list);
    } else {
      lastApprovedEdit = null;
      currentWordNotifier.value = currentWordNotifier.value.copyWith(
          state: RequestState.error,
          didSucced: false,
          message: 'Failed',
          status: resp.status,
          data: lastApprovedEdit);
    }
  }

  ValueNotifier<Response> currentWordNotifier = ValueNotifier<Response>(
      Response(didSucced: false, message: 'Failed', status: 400, data: Word('', '', '')));

  /// edit from database before the current edit
  EditHistory? lastApprovedEdit;

  EditHistory? currentEdit;

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
    return ValueListenableBuilder<Response>(
        valueListenable: currentWordNotifier,
        builder: (context, Response value, child) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                title: Text(widget.title),
                actions: [
                  if (value.state == RequestState.done)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${currentEdit?.state!.name.capitalize()!}',
                        ),
                        Text('Type: ${currentEdit?.edit_type!.name.capitalize()!}'),
                      ],
                    ),
                  8.0.hSpacer()
                ],
              ),
              body: currentEdit == null || lastApprovedEdit == null
                  ? LoadingWidget()
                  : Column(
                      children: [
                        DifferenceVisualizer(
                            title: 'Word',
                            newVersion: currentEdit!.word,
                            oldVersion: lastApprovedEdit!.word),
                        DifferenceVisualizer(
                            title: 'Meaning',
                            newVersion: currentEdit!.meaning,
                            oldVersion: lastApprovedEdit!.meaning),
                        DifferenceVisualizer(
                            title: 'Synonyms',
                            newVersion: currentEdit!.synonyms!.join(','),
                            oldVersion: lastApprovedEdit!.synonyms!.join(',')),
                        DifferenceVisualizer(
                            title: 'Examples',
                            newVersion: currentEdit!.examples!.join(','),
                            oldVersion: lastApprovedEdit!.examples!.join(',')),
                        DifferenceVisualizer(
                            title: 'Mnemonics',
                            newVersion: currentEdit!.mnemonics!.join(','),
                            oldVersion: lastApprovedEdit!.mnemonics!.join(',')),
                        ListTile(
                          title: Text('Comments'),
                          subtitle: Text(
                            currentEdit!.comments,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        ListTile(
                          leading: CircularAvatar(
                            name: currentEdit!.users_mobile!.name,
                            url: currentEdit!.users_mobile!.avatarUrl,
                          ),
                          subtitle: Text(currentEdit!.created_at!.toLocal().standardDateTime()),
                          title: Text(currentEdit!.users_mobile!.name),
                        ),
                      ],
                    ));
        });
  }
}
