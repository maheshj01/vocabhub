import 'package:flutter/material.dart';

enum SlideTransitionType { ltr, rtl, ttb, btt, bl, br, tl, tr }

Future<void> navigateReplace(BuildContext context, Widget widget,
        {bool isDialog = false,
        bool isRootNavigator = true,
        SlideTransitionType type = SlideTransitionType.tr}) async =>
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget, type: type));

Future<void> navigate(BuildContext context, Widget widget,
        {bool isDialog = false,
        bool isRootNavigator = true,
        SlideTransitionType type = SlideTransitionType.tr}) =>
    Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget, type: type));
// pop all Routes except first
void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
    Navigator.of(context, rootNavigator: isRootNavigator)
        .popUntil((route) => route.isFirst);

void popView(BuildContext context, {bool isRootNavigator = true}) async =>
    Navigator.of(context, rootNavigator: isRootNavigator).pop();

navigateAndPopAll(BuildContext context, Widget widget,
        {bool isRootNavigator = true}) =>
    Navigator.of(context, rootNavigator: isRootNavigator).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => widget),
        (Route<dynamic> route) => false);

Offset getTransitionOffset(SlideTransitionType type) {
  switch (type) {
    case SlideTransitionType.ltr:
      return Offset(-1.0, 0.0);
    case SlideTransitionType.rtl:
      return Offset(1.0, 0.0);
    case SlideTransitionType.ttb:
      return Offset(0.0, -1.0);
    case SlideTransitionType.btt:
      return Offset(0.0, 1.0);
    case SlideTransitionType.bl:
      return Offset(-1.0, 1.0);
    case SlideTransitionType.br:
      return Offset(1.0, 1.0);
    case SlideTransitionType.tl:
      return Offset(-1.0, -1.0);
    case SlideTransitionType.tr:
      return Offset(1.0, 1.0);
    default:
      return Offset(1.0, 0.0);
  }
}

class NavigateRoute extends PageRouteBuilder {
  final Widget widget;
  final bool? rootNavigator;
  final SlideTransitionType type;
  NavigateRoute(this.widget, {this.rootNavigator, required this.type})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
