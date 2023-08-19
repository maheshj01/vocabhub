import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/empty_page.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(desktopBuilder: (context) {
      return Drafts();
    }, mobileBuilder: (context) {
      return Drafts();
    });
  }
}

class Drafts extends StatefulWidget {
  const Drafts({super.key});

  @override
  State<Drafts> createState() => _DraftsState();
}

class _DraftsState extends State<Drafts> {
  @override
  void initState() {
    getDrafts();
    super.initState();
  }

  Future<void> getDrafts() async {
    try {
      _requestNotifier.value = _requestNotifier.value.copyWith(state: RequestState.active);
      final drafts = await addWordController.loadDrafts();
      _requestNotifier.value =
          _requestNotifier.value.copyWith(data: drafts, state: RequestState.done);
    } catch (_) {
      _requestNotifier.value = _requestNotifier.value
          .copyWith(state: RequestState.error, message: "Failed to load drafts");
    }
  }

  ValueNotifier<Response> _requestNotifier =
      ValueNotifier(Response(didSucced: false, message: "Failed"));

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Column(
          children: [
            AppBar(
              title: Text('Drafts'),
              backgroundColor: Colors.transparent,
              // elevation: 0,
            ),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _requestNotifier,
                  builder: (context, Response value, child) {
                    if (value.state == RequestState.active) {
                      return LoadingWidget();
                    }
                    if (value.state == RequestState.error) {
                      return ErrorPage(
                          onRetry: () async {
                            await getDrafts();
                          },
                          errorMessage: value.message);
                    }
                    final drafts = value.data as List<Word>;
                    if (drafts.isEmpty) {
                      return EmptyPage(
                        message: 'No drafts found',
                      );
                    }
                    return ListView.builder(
                        itemCount: drafts.length,
                        itemBuilder: (context, index) {
                          final draft = drafts[index];
                          return ListTile(
                            title: Text('${draft.word}'),
                            subtitle: Text('${draft.meaning}'),
                            onTap: () {
                              Navigate.popView(context, value: drafts[index]);
                              addWordController.removeDraft(draft);
                            },
                          );
                        });
                  }),
            ),
          ],
        ));
  }
}
