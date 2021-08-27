// import 'dart:js' as js;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// shows a snackbar message
void showMessage(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2),
    bool isRoot = false,
    void Function()? onPressed,
    void Function()? onClosed}) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text('$message'),
          duration: duration,
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

/// TODO: Add canLaunch condition back when this issue is fixed https://github.com/flutter/flutter/issues/74557
Future<void> launchUrl(String url, {bool isNewTab = true}) async {
  // await canLaunch(url)
  // ?
  await launch(
    url,
    webOnlyWindowName: isNewTab ? '_blank' : '_self',
  );
  // : throw 'Could not launch $url';
}

String getInitial(String text) {
  if (text != null && text.isNotEmpty) {
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
