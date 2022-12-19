import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/report.dart';
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
        desktopBuilder: (context) => ReportABugMobile(),
        mobileBuilder: (context) => ReportABugMobile());
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
    _responseNotifier.dispose();
    super.dispose();
  }

  Future<void> getReports() async {
    try {
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.active, message: 'Loading', data: null);
      final reports = await ReportService.getReports();
      _responseNotifier.value = _responseNotifier.value.copyWith(
          state: RequestState.done, message: 'Success', data: reports);
    } catch (e) {
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.error, message: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getReports();
  }

  final ValueNotifier<Response> _responseNotifier =
      ValueNotifier(Response.init());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reports and Feedbacks'),
        ),
        body: ValueListenableBuilder<Response>(
            valueListenable: _responseNotifier,
            builder: (BuildContext context, Response request, Widget? child) {
              if (request.state == RequestState.active) {
                return const LoadingWidget();
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
                        child: const Text('Try Again'),
                      ),
                      Text(request.message),
                    ],
                  ),
                );
              }
              List<ReportModel> reports = request.data as List<ReportModel>;
              if (reports.isEmpty) {
                return const Center(
                  child: Text('No reports yet'),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: AnimatedList(
                        itemBuilder: (context, index, animation) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpansionTile(
                                subtitle: Text(reports[index]
                                        .created_at
                                        .standardDate() +
                                    ' ' +
                                    reports[index].created_at.standardTime()),
                                title: Text(reports[index].name),
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                expandedAlignment: Alignment.centerLeft,
                                children: [
                                  Padding(
                                    padding: 16.0.allPadding,
                                    child: Text(reports[index].feedback,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87)),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        initialItemCount: (request.data as List).length),
                  ),
                  24.0.vSpacer()
                ],
              );
            }));
  }
}

class ReportABugMobile extends StatefulWidget {
  static const String route = '/report';

  @override
  State<ReportABugMobile> createState() => _ReportABugMobileState();
}

class _ReportABugMobileState extends State<ReportABugMobile> {
  ValueNotifier<Response> _responseNotifier = ValueNotifier(Response.init());

  @override
  void dispose() {
    _feedBackcontroller.dispose();
    _responseNotifier.dispose();
    super.dispose();
  }

  final TextEditingController _feedBackcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a bug'),
      ),
      body: ValueListenableBuilder<Response>(
          valueListenable: _responseNotifier,
          builder: (context, value, snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  24.0.vSpacer(),
                  VHTextfield(
                    hint: 'Description of the bug',
                    hasLabel: false,
                    controller: _feedBackcontroller,
                    maxLines: 8,
                  ),
                  24.0.vSpacer(),
                  VHButton(
                      height: 48,
                      onTap: () async {
                        removeFocus(context);
                        _responseNotifier.value = _responseNotifier.value
                            .copyWith(state: RequestState.active);
                        String description = _feedBackcontroller.text.trim();
                        if (description.isEmpty) {
                          showMessage(context,
                              'You must enter a description of the bug');
                          _responseNotifier.value = _responseNotifier.value
                              .copyWith(state: RequestState.done);
                          return;
                        }
                        _responseNotifier.value = _responseNotifier.value
                            .copyWith(
                                state: RequestState.active,
                                message: 'Sending report');
                        try {
                          final report = ReportModel(
                              feedback: description,
                              email: user!.email,
                              created_at: DateTime.now(),
                              id: Uuid().v4(),
                              name: user.name);
                          final resp = await ReportService.addReport(report);
                          if (resp.status == 201) {
                            _responseNotifier.value = _responseNotifier.value
                                .copyWith(
                                    state: RequestState.done,
                                    message: 'Report sent successfully');
                            _responseNotifier.value = _responseNotifier.value
                                .copyWith(state: RequestState.done);
                            showMessage(
                                context, 'Thanks for reporting the bug');
                            _feedBackcontroller.clear();
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.pop(context);
                          } else {
                            _responseNotifier.value = _responseNotifier.value
                                .copyWith(
                                    state: RequestState.done,
                                    message: 'Error sending report');
                            showMessage(
                                context, 'Error sending report! Try again');
                          }
                        } catch (e) {
                          _responseNotifier.value = _responseNotifier.value
                              .copyWith(
                                  state: RequestState.done,
                                  message: 'Error sending report');
                          showMessage(
                              context, 'Something went wrong, try agcain');
                        }
                      },
                      isLoading:
                          _responseNotifier.value.state == RequestState.active,
                      foregroundColor: Colors.white,
                      backgroundColor: VocabTheme.primaryColor,
                      label: 'Submit'),
                  Padding(
                    padding: 16.0.allPadding,
                    child: Text(
                        'Note: We may contact you for more information about the bug you reported.'),
                  ),
                  24.0.vSpacer(),
                ],
              ),
            );
          }),
    );
  }
}
