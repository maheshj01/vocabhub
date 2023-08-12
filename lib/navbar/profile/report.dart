import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/report.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/profile/profile.dart';
import 'package:vocabhub/services/services/report_service.dart';
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
    return ResponsiveBuilder(
        desktopBuilder: (context) => ReportABugMobile(),
        mobileBuilder: (context) => ReportABugMobile());
  }
}

class ViewBugReports extends StatefulWidget {
  const ViewBugReports({super.key});

  @override
  State<ViewBugReports> createState() => _ViewBugReportsState();
}

class _ViewBugReportsState extends State<ViewBugReports> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(desktopBuilder: (ctx) {
      return ViewBugReportsMobile();
    }, mobileBuilder: (ctx) {
      return ViewBugReportsMobile();
    });
  }
}

class ViewBugReportsMobile extends StatefulWidget {
  const ViewBugReportsMobile({Key? key}) : super(key: key);

  @override
  State<ViewBugReportsMobile> createState() => _ViewBugReportsMobileState();
}

class _ViewBugReportsMobileState extends State<ViewBugReportsMobile> {
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
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.done, message: 'Success', data: reports);
    } catch (e) {
      _responseNotifier.value =
          _responseNotifier.value.copyWith(state: RequestState.error, message: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getReports();
  }

  final ValueNotifier<Response> _responseNotifier = ValueNotifier(Response.init());

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Column(
          children: [
            AppBar(
              title: const Text('Reports and Feedbacks'),
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: ValueListenableBuilder<Response>(
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
                              onPressed: getReports,
                              child: const Text('Try Again'),
                            ),
                            Text(request.message),
                          ],
                        ),
                      );
                    }
                    Map<String, List<ReportModel>> reports =
                        request.data as Map<String, List<ReportModel>>;
                    if (reports.isEmpty) {
                      return const Center(
                        child: Text('No reports yet'),
                      );
                    }
                    final List<String> keys = reports.keys.toList();
                    final List<List<ReportModel>> values = reports.values.toList();
                    return ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('${reports.values.elementAt(index).first.name}',
                                style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(reports.values.elementAt(index).first.email,
                                style: Theme.of(context).textTheme.bodyMedium),
                            trailing: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              maxRadius: 16,
                              child: Text(
                                '${reports.values.elementAt(index).length}',
                                style: TextStyle(
                                    fontSize: 18, color: Theme.of(context).colorScheme.onSecondary),
                              ),
                            ),
                            onTap: () {
                              Navigate.push(
                                  context,
                                  ViewReportsByUser(
                                    email: keys[index],
                                    reports: values[index],
                                    title: values[index].first.name,
                                    shouldFetchReport: false,
                                  ));
                            },
                          );
                        },
                        itemCount: reports.length);
                  }),
            ),
          ],
        ));
  }
}

class ViewReportsByUser extends StatefulWidget {
  final List<ReportModel> reports;
  final String email;

  /// If true, fetch reports from the server
  /// else use the reports passed in [reports]
  final bool shouldFetchReport;
  final String title;

  const ViewReportsByUser(
      {Key? key,
      required this.reports,
      required this.email,
      this.shouldFetchReport = false,
      this.title = ''})
      : super(key: key);

  @override
  State<ViewReportsByUser> createState() => _ViewReportsByUserState();
}

class _ViewReportsByUserState extends State<ViewReportsByUser> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ViewReportsByUserMobile(
            reports: widget.reports,
            email: widget.email,
            shouldFetchReport: widget.shouldFetchReport,
            title: widget.title),
        mobileBuilder: (context) => ViewReportsByUserMobile(
            reports: widget.reports,
            email: widget.email,
            shouldFetchReport: widget.shouldFetchReport,
            title: widget.title));
  }
}

/// View reports by a user
/// [shouldFetchReport] if true, fetch reports from the server
/// or use the reports passed in [reports] and [email]
/// [reports] is the list of reports to display
/// [email] is the email of the user
class ViewReportsByUserMobile extends StatefulWidget {
  final List<ReportModel> reports;
  final String email;

  /// If true, fetch reports from the server
  /// else use the reports passed in [reports]
  final bool shouldFetchReport;
  final String title;

  const ViewReportsByUserMobile(
      {Key? key,
      required this.reports,
      required this.email,
      this.shouldFetchReport = false,
      this.title = ''})
      : super(key: key);

  @override
  State<ViewReportsByUserMobile> createState() => _ViewReportsByUserMobileState();
}

class _ViewReportsByUserMobileState extends State<ViewReportsByUserMobile> {
  final ValueNotifier<Response> _responseNotifier = ValueNotifier(Response.init());

  Future<void> getReportsByEmail(bool isRetry) async {
    if (!isRetry) {
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.done, message: 'Loaded', data: widget.reports);
      return;
    }
    try {
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.active, message: 'Loading', data: null);
      final reports = await ReportService.getReportByEmail(widget.email);
      _responseNotifier.value = _responseNotifier.value
          .copyWith(state: RequestState.done, message: 'Success', data: reports);
    } catch (e) {
      _responseNotifier.value =
          _responseNotifier.value.copyWith(state: RequestState.error, message: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getReportsByEmail(widget.shouldFetchReport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: GestureDetector(
              onTap: () {
                if (widget.shouldFetchReport) return;

                /// admin can view user profile
                Navigate.push(
                    context,
                    Scaffold(
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          centerTitle: false,
                          title: Text(
                            'Profile',
                          ),
                        ),
                        body: UserProfile(
                          email: widget.email,
                          isReadOnly: true,
                        )));
              },
              child: Text('${widget.title}')),
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
                        onPressed: () => getReportsByEmail(true),
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
              return RefreshIndicator(
                onRefresh: () async {
                  await getReportsByEmail(true);
                },
                child: Padding(
                  padding: 16.0.allPadding,
                  child: AnimatedList(
                      itemBuilder: (context, index, animation) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${reports[index].created_at.standardDate()} ${reports[index].created_at.standardTime()}'),
                            4.0.vSpacer(),
                            Container(
                              padding: 16.0.allPadding,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                '${reports[index].feedback}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                              ),
                            ),
                            16.0.vSpacer(),
                          ],
                        );
                      },
                      initialItemCount: (request.data as List).length),
                ),
              );
            }));
  }
}

class ReportABugMobile extends ConsumerStatefulWidget {
  static const String route = '/report';

  @override
  _ReportABugMobileState createState() => _ReportABugMobileState();
}

class _ReportABugMobileState extends ConsumerState<ReportABugMobile> {
  ValueNotifier<Response> _responseNotifier = ValueNotifier(Response.init());

  @override
  void dispose() {
    _feedBackcontroller.dispose();
    _responseNotifier.dispose();
    super.dispose();
  }

  final TextEditingController _feedBackcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// Show ratings after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        showRatingsBottomSheet(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ValueListenableBuilder<Response>(
          valueListenable: _responseNotifier,
          builder: (context, value, snapshot) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Report a bug'),
                    backgroundColor: Colors.transparent,
                  ),
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
                        _responseNotifier.value =
                            _responseNotifier.value.copyWith(state: RequestState.active);
                        final String description = _feedBackcontroller.text.trim();
                        if (description.isEmpty) {
                          NavbarNotifier.showSnackBar(
                              context, 'You must enter a description of the bug',
                              bottom: 0);
                          _responseNotifier.value =
                              _responseNotifier.value.copyWith(state: RequestState.done);
                          return;
                        }
                        _responseNotifier.value = _responseNotifier.value
                            .copyWith(state: RequestState.active, message: 'Sending report');
                        try {
                          final report = ReportModel(
                              feedback: description,
                              email: user.email,
                              created_at: DateTime.now(),
                              id: Uuid().v4(),
                              name: user.name);
                          final resp = await ReportService.addReport(report);
                          if (resp.status == 201) {
                            _responseNotifier.value = _responseNotifier.value.copyWith(
                                state: RequestState.done, message: 'Report sent successfully');
                            _responseNotifier.value =
                                _responseNotifier.value.copyWith(state: RequestState.done);
                            NavbarNotifier.showSnackBar(context, 'Thanks for reporting the bug');
                            pushNotificationService.sendNotification(Constants.reportPayLoad(
                                'A new bug report', '${user.name}: $description'));
                            _feedBackcontroller.clear();
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.pop(context);
                          } else {
                            _responseNotifier.value = _responseNotifier.value.copyWith(
                                state: RequestState.done, message: 'Error sending report');
                            NavbarNotifier.showSnackBar(context, 'Error sending report! Try again');
                          }
                        } catch (e) {
                          _responseNotifier.value = _responseNotifier.value
                              .copyWith(state: RequestState.done, message: 'Error sending report');
                          NavbarNotifier.showSnackBar(context, 'Something went wrong, try agcain');
                        }
                      },
                      isLoading: _responseNotifier.value.state == RequestState.active,
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
