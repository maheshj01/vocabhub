import 'package:flutter/material.dart';

enum SlideTransitionType { ltr, rtl, ttb, btt, bl, br, tl, tr }

class Navigate<T> {
  /// Replace the top widget with another widget
  Future<T?> pushReplace(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      SlideTransitionType slideTransitionType = SlideTransitionType.tr}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget, type: slideTransitionType));
    return value;
  }

  Future<T?> push(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      SlideTransitionType slideTransitionType =
          SlideTransitionType.btt}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget, type: slideTransitionType));
    return value;
  }

// pop all Routes except first
  static void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .popUntil((route) => route.isFirst);

  void popView(BuildContext context,
          {T? value, bool isRootNavigator = true}) async =>
      Navigator.of(context, rootNavigator: isRootNavigator).pop(value);

  Future<T?> pushAndPopAll(BuildContext context, Widget widget,
      {bool isRootNavigator = true,
      SlideTransitionType slideTransitionType = SlideTransitionType.tr}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushAndRemoveUntil(NavigateRoute(widget, type: slideTransitionType),
            (Route<dynamic> route) => false);
    return value;
  }
}

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
