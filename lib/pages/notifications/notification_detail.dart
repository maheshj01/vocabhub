import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:supabase/supabase.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/profile/profile.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NotificationDetail extends StatefulWidget {
  final EditHistory editHistory;

  static const String route = '/';

  const NotificationDetail({Key? key, required this.editHistory}) : super(key: key);

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationDetailMobile(
              word: widget.editHistory.word,
            ),
        mobileBuilder: (context) => NotificationDetailMobile(
              word: widget.editHistory.word,
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

class NotificationDetailMobile extends StatefulWidget {
  String word;
  String title;

  NotificationDetailMobile({
    Key? key,
    this.title = 'Edit Detail',
    required this.word,
  }) : super(key: key);

  @override
  State<NotificationDetailMobile> createState() => _NotificationDetailMobileState();
}

class _NotificationDetailMobileState extends State<NotificationDetailMobile> {
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
    resp = await EditHistoryService.findPreviousEditsByWord(widget.word);
    // findById(widget.edit_history.word_id);
    if (resp.status == 200) {
      list = (resp.data as List).map((e) => EditHistory.fromJson(e)).toList();
      currentWordNotifier.value = currentWordNotifier.value.copyWith(
          state: RequestState.done, didSucced: true, message: 'Success', status: 200, data: list);
    } else {
      lastApprovedEdit = Word('', '', '');
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
  late Word lastApprovedEdit = Word('', '', '');

  @override
  void initState() {
    super.initState();
    getCurrentWord();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: ValueListenableBuilder<Response>(
            valueListenable: currentWordNotifier,
            builder: (context, Response value, Widget? child) {
              if (value.state == RequestState.active) {
                return LoadingWidget();
              }
              List<EditHistory> list = (value.data as List<EditHistory>);
              return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final editHistory = list[index];
                    return ExpansionTile(
                      leading: CircularAvatar(
                        name: editHistory.users_mobile!.name,
                        url: editHistory.users_mobile!.avatarUrl,
                      ),
                      title: Text(editHistory.word),
                      iconColor: Colors.red,
                      onExpansionChanged: (x) {},
                      subtitle: Text(editHistory.created_at!.standardDateTime()),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${editHistory.state!.name.capitalize()!}',
                            style: TextStyle(
                              color: stateToIconColor(editHistory.state!),
                            ),
                          ),
                          Text('Type: ${editHistory.edit_type!.name.capitalize()!}'),
                        ],
                      ),
                      children: [
                        ListTile(
                          title: Text('Meaning'),
                          subtitle: Text(editHistory.meaning),
                        ),
                        ListTile(
                          title: Text('Synonyms'),
                          subtitle: Text(editHistory.synonyms!.join(',')),
                        ),
                        ListTile(
                          title: Text('Examples'),
                          subtitle: Text(editHistory.examples!.join(',')),
                        ),
                        ListTile(
                          title: Text('Mnemonics'),
                          subtitle: Text(editHistory.mnemonics!.join(',')),
                        ),
                        ListTile(
                            title: Text('Edited By'),
                            subtitle: Text(editHistory.users_mobile!.name),
                            onTap: () {
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
                                        email: editHistory.users_mobile!.email,
                                        isReadOnly: true,
                                      )));
                            },
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                            )),
                      ],
                    );
                  });
              // List<Widget> _children = [
              //   widget.editHistory.edit_type == EditType.edit
              //       ? Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Old Version',
              //               style: Theme.of(context).textTheme.titleLarge,
              //             ),
              //             16.0.vSpacer(),
              //             heading('Word'),
              //             8.0.vSpacer(),
              //             differenceVisualizerGranular(currentEdit.word, lastApprovedEdit.word,
              //                 isOldVersion: true),
              //             8.0.vSpacer(),
              //             heading('Meaning'),
              //             8.0.vSpacer(),
              //             differenceVisualizerGranular(
              //                 currentEdit.meaning, lastApprovedEdit.meaning,
              //                 isOldVersion: true),
              //             8.0.vSpacer(),
              //             heading('Synonyms'),
              //             8.0.vSpacer(),
              //             differenceVisualizerGranular(
              //                 currentEdit.synonyms!.join(','), lastApprovedEdit.synonyms!.join(','),
              //                 isOldVersion: true),
              //             8.0.vSpacer(),
              //             heading('Examples'),
              //             8.0.vSpacer(),
              //             differenceVisualizerGranular(
              //                 currentEdit.examples!.join(','), lastApprovedEdit.examples!.join(','),
              //                 isOldVersion: true),
              //             8.0.vSpacer(),
              //             heading('Mnemonics'),
              //             8.0.vSpacer(),
              //             differenceVisualizerGranular(currentEdit.mnemonics!.join(','),
              //                 lastApprovedEdit.mnemonics!.join(','),
              //                 isOldVersion: true),
              //             Padding(
              //               padding: 8.0.verticalPadding,
              //               child: hLine(),
              //             ),
              //           ],
              //         )
              //       : SizedBox.shrink(),
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         editType == EditType.add ? 'New Word' : 'New Version',
              //         style: Theme.of(context).textTheme.titleLarge,
              //       ),
              //       16.0.vSpacer(),
              //       heading('Word'),
              //       8.0.vSpacer(),
              //       differenceVisualizerGranular(currentEdit.word, lastApprovedEdit.word,
              //           isOldVersion: false),
              //       8.0.vSpacer(),
              //       heading('Meaning'),
              //       8.0.vSpacer(),
              //       differenceVisualizerGranular(currentEdit.meaning, lastApprovedEdit.meaning,
              //           isOldVersion: false),
              //       8.0.vSpacer(),
              //       heading('Synonyms'),
              //       8.0.vSpacer(),
              //       differenceVisualizerGranular(
              //           currentEdit.synonyms!.join(','), lastApprovedEdit.synonyms!.join(','),
              //           isOldVersion: false),
              //       8.0.vSpacer(),
              //       heading('Examples'),
              //       8.0.vSpacer(),
              //       differenceVisualizerGranular(
              //           currentEdit.examples!.join(','), lastApprovedEdit.examples!.join(','),
              //           isOldVersion: false),
              //       8.0.vSpacer(),
              //       heading('Mnemonics'),
              //       8.0.vSpacer(),
              //       differenceVisualizerGranular(
              //           currentEdit.mnemonics!.join(','), lastApprovedEdit.mnemonics!.join(','),
              //           isOldVersion: false),
              //       8.0.vSpacer(),
              //     ],
              //   )
              // ];
              // return Padding(
              //     padding: 12.0.horizontalPadding,
              //     child: SingleChildScrollView(
              //       scrollDirection: SizeUtils.isDesktop ? Axis.horizontal : Axis.vertical,
              //       child: SizeUtils.isMobile
              //           ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: _children)
              //           : Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: _children,
              //             ),
              //     ));
            }));
  }
}

/// Authenticate User using social auth
/// Allow users to post their ad
///
