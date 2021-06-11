// import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showMessage(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2),
    void Function()? onPressed}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('$message'),
    duration: duration,
    action: onPressed == null
        ? null
        : SnackBarAction(label: 'ACTION', onPressed: onPressed),
  ));
}

Future<void> launchUrl(String url, {bool isNewTab = true}) async {
  await canLaunch(url)
      ? await launch(
          url,
          webOnlyWindowName: isNewTab ? '_blank' : '_self',
        )
      : throw 'Could not launch $url';
}
