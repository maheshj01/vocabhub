import 'dart:js' as js;
import 'package:flutter/material.dart';

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

void launchUrl(String url, {bool isNewTab = true}) {
  js.context.callMethod('open', ['$url', isNewTab ? '_blank' : '_self']);
}
