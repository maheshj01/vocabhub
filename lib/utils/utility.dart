import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';

/// shows a snackbar message
void showMessage(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2),
    bool isRoot = false,
    double bottom = 0,
    void Function()? onPressed,
    void Function()? onClosed}) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text(
            '$message',
          ),
          duration: duration,
          // margin: EdgeInsets.only(bottom: bottom),
          action: onPressed == null
              ? null
              : SnackBarAction(
                  label: 'ACTION',
                  onPressed: onPressed,
                ),
        ),
      )
      .closed
      .whenComplete(() => onClosed == null ? null : onClosed());
}

void hideMessage(context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

void showToast(String message) {
  Fluttertoast.showToast(
      msg: "$message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 12.0);
}

void hideToast() {
  Fluttertoast.cancel();
}

/// TODO: Add canLaunch condition back when this issue is fixed https://github.com/flutter/flutter/issues/74557
Future<void> launchURL(String url, {bool isNewTab = true}) async {
  // await canLaunch(url)
  // ?
  await launchUrl(
    Uri.parse(url),
    webOnlyWindowName: isNewTab ? '_blank' : '_self',
  );
  // : throw 'Could not launch $url';
}

String getInitial(String text) {
  if (text.isNotEmpty) {
    if (text.contains(' ')) {
      final list = text.split(' ').toList();
      return list[0].substring(0, 1) + list[1].substring(0, 1);
    } else {
      return text.substring(0, 1);
    }
  } else {
    return 'N/A';
  }
}

double diagonal(Size size) {
  return pow(pow(size.width, 2) + pow(size.width, 2), 0.5) as double;
}

String buildShareMessage(Word word) {
  return '''
  I just learned this word on VocabHub: ${word.word}
  Meaning: ${word.meaning}

  You can learn too by downloading the VocabHub app at: ${Constants.PLAY_STORE_URL}
  ''';
}

// void _openCustomDialog(BuildContext context) {
//   showGeneralDialog(
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionBuilder: (context, a1, a2, widget) {
//         return Transform.translate(
//             offset: Offset(0, 100 * a1.value), child: AddWordForm());
//       },
//       transitionDuration: Duration(milliseconds: 500),
//       barrierDismissible: true,
//       barrierLabel: '',
//       context: context,
//       pageBuilder: (context, animation1, animation2) {
//         return Container();
//       });
// }

Widget _buildNewTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return Transform.translate(
    offset: Offset(0, animation.value * -50),
    child: child,
  );
}

/// Returns a boolean value whether the window is considered medium or large size.
///
/// Used to build adaptive and responsive layouts.
// bool isDisplayDesktop(BuildContext context) =>
//     getWindowType(context) >= AdaptiveWindowType.medium;

// /// Returns boolean value whether the window is considered medium size.
// ///
// /// Used to build adaptive and responsive layouts.
// bool isDisplayMediumDesktop(BuildContext context) {
//   return getWindowType(context) == AdaptiveWindowType.medium;
// }

// bool isDisplaySmallDesktop(BuildContext context) {
//   return getWindowType(context) == AdaptiveWindowType.xsmall;
// }

String editTypeToUserNotification(EditHistory history, UserModel editor) {
  final String statefilter =
      '${history.state == EditState.pending ? 'under review' : history.state!.toName()}';

  if (history.edit_type == EditType.add) {
    return 'Request to add ${history.word} $statefilter';
  } else if (history.edit_type == EditType.delete) {
    return 'Request to delete ${history.word} $statefilter';
  } else if (history.edit_type == EditType.edit) {
    return 'Request to update ${history.word} $statefilter';
  }
  return '';
}

String editTypeToAdminNotification(EditHistory history, UserModel editor) {
  final bool adminRequest = editor.isAdmin;
  // final String statefilter =
  //     '${history.state == EditState.pending ? 'under review' : history.state!.toName()}';
  final String userFilter = adminRequest ? 'You Requested' : '${editor.name} Requested';

  /// TODO: handle adminRequest
  /// and separate notification generator for admin and user
  if (history.edit_type == EditType.add) {
    return '$userFilter to add ${history.word}';
  } else if (history.edit_type == EditType.delete) {
    return '$userFilter to delete ${history.word}';
  } else if (history.edit_type == EditType.edit) {
    return '$userFilter to update ${history.word}';
  }
  return '';
}

class ResponseObject {
  final String message;
  final Object data;
  final Status status;

  ResponseObject(this.message, this.data, this.status);
}

class Response {
  bool didSucced;
  String message;
  int? status;
  Object? data;
  RequestState state;

  Response(
      {this.didSucced = false,
      this.message = 'Success',
      this.status,
      this.data,
      this.state = RequestState.none});
  Response.init(
      {this.didSucced = true,
      this.state = RequestState.none,
      this.message = 'Success',
      this.status,
      this.data});

  Response copyWith(
      {bool? didSucced, String? message, int? status, Object? data, RequestState? state}) {
    return Response(
        didSucced: didSucced ?? this.didSucced,
        message: message ?? this.message,
        status: status ?? this.status,
        data: data ?? this.data,
        state: state ?? this.state);
  }
}
