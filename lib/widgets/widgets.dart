import 'package:flutter/material.dart';

/** 
 * Small helper widgets go here in this page
 * for custom large widgets consider creating 
 * a separate file under lib/widgets
 */

void removeFocus(BuildContext context) => FocusScope.of(context).unfocus();

void showCircularIndicator(BuildContext context, {Color? color}) {
  removeFocus(context);
  showDialog<void>(
      barrierColor: color,
      context: context,
      barrierDismissible: false,
      builder: (x) => LoadingWidget());
}

void stopCircularIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
