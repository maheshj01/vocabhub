import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/models/report.dart';
import 'package:vocabhub/models/request.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/report_service.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class ReportABug extends StatefulWidget {
  static const String route = '/report';

  const ReportABug({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportABug> createState() => _ReportABugState();
}

class _ReportABugState extends State<ReportABug> {
  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return ResponsiveBuilder(
        desktopBuilder: (context) => ReportABugDesktop(),
        mobileBuilder: (context) =>
            user!.isAdmin ? ViewBugReports() : ReportABugMobile());
  }
}

class ReportABugDesktop extends StatefulWidget {
  const ReportABugDesktop({Key? key}) : super(key: key);

  @override
  State<ReportABugDesktop> createState() => _ReportABugDesktopState();
}

class _ReportABugDesktopState extends State<ReportABugDesktop> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}

class ViewBugReports extends StatefulWidget {
  const ViewBugReports({Key? key}) : super(key: key);

  @override
  State<ViewBugReports> createState() => _ViewBugReportsState();
}

class _ViewBugReportsState extends State<ViewBugReports> {
  @override
  void dispose() {
    _request.dispose();
    super.dispose();
  }

  Future<void> getReports() async {
    try {
      _request.value =
          Request(RequestState.active, message: 'Loading', data: null);
      final reports = await ReportService.getReports();
      _request.value =
          Request(RequestState.done, message: 'Success', data: reports);
    } catch (e) {
      _request.value = Request(RequestState.error, message: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getReports();
  }

  ValueNotifier<Request> _request = ValueNotifier(Request(RequestState.none));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reports and Feedbacks'),
        ),
        body: ValueListenableBuilder<Request>(
            valueListenable: _request,
            builder: (BuildContext context, Request request, Widget? child) {
              if (request.state == RequestState.active) {
                return LoadingWidget();
              }
              if (request.state == RequestState.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          getReports();
                        },
                        child: Text('Try Again'),
                      ),
                      Text(request.message!),
                    ],
                  ),
                );
              }
              List<ReportModel> reports = request.data as List<ReportModel>;
              if (reports.isEmpty) {
                return Center(
                  child: Text('No reports yet'),
                );
              }
              return AnimatedList(
                  itemBuilder: (context, index, animation) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(reports[index].name),
                          subtitle: Text(reports[index].email),
                          trailing:
                              Text(reports[index].created_at.standardDate()),
                          // subtitle: Text(reports[index].feedback * 100),
                        ),
                        Padding(
                          padding: 16.0.horizontalPadding,
                          child: Text(reports[index].feedback),
                        ),
                        Divider(),
                      ],
                    );
                  },
                  initialItemCount: (request.data as List).length);
            }));
  }
}

class ReportABugMobile extends StatefulWidget {
  const ReportABugMobile({Key? key}) : super(key: key);

  @override
  State<ReportABugMobile> createState() => _ReportABugMobileState();
}

class _ReportABugMobileState extends State<ReportABugMobile> {
  ValueNotifier<Request> _request = ValueNotifier(Request(RequestState.none));

  @override
  void dispose() {
    _request.dispose();
    _controller.dispose();
    super.dispose();
  }

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a bug'),
      ),
      body: ValueListenableBuilder<Request>(
          valueListenable: _request,
          builder: (context, value, snapshot) {
            return Column(
              children: [
                24.0.vSpacer(),
                VHTextfield(
                  hint: 'Description of the bug',
                  hasLabel: false,
                  controller: _controller,
                  maxLines: 8,
                ),
                24.0.vSpacer(),
                VHButton(
                    height: 48,
                    onTap: () async {
                      _request.value = Request(RequestState.active);
                      try {
                        final report = ReportModel(
                            feedback: _controller.text.trim(),
                            email: user!.email,
                            created_at: DateTime.now(),
                            id: Uuid().v4(),
                            name: user.name);
                        await ReportService.addReport(report);
                        _request.value = Request(RequestState.done);
                        showMessage(context, 'Thanks for reporting the bug');
                      } catch (e) {
                        _request.value =
                            Request(RequestState.error, message: e.toString());
                        showMessage(
                            context, 'Something went wrong, try agcain');
                      }
                    },
                    isLoading: _request.value.state == RequestState.active,
                    foregroundColor: Colors.white,
                    backgroundColor: VocabTheme.primaryColor,
                    label: 'Submit'),
                Expanded(child: Container()),
                Padding(
                  padding: 16.0.allPadding,
                  child: Text(
                      'Note: We may contact you for more information about the bug you reported.'),
                ),
                24.0.vSpacer(),
              ],
            );
          }),
    );
  }
}
