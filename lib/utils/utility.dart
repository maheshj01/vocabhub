// import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

Future<void> launchUrl(String url, {bool isNewTab = true}) async {
  await canLaunch(url)
      ? await launch(
          url,
          webOnlyWindowName: isNewTab ? '_blank' : '_self',
        )
      : throw 'Could not launch $url';
}
