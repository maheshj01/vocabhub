import 'package:flutter/material.dart';

enum TransitionType { ltr, rtl, ttb, btt, bl, br, tl, tr, scale }

class Navigate<T> {
  /// Replace the top widget with another widget
  Future<T?> pushReplace(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget, type: slideTransitionType));
    return value;
  }

  static Future<void> push(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    final value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget, type: slideTransitionType));
    // return value;
  }

// pop all Routes except first
  static void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .popUntil((route) => route.isFirst);

  Future<void> popView(BuildContext context,
          {T? value, bool isRootNavigator = true}) async =>
      Navigator.of(context, rootNavigator: isRootNavigator).pop(value);

  Future<T?> pushAndPopAll(BuildContext context, Widget widget,
      {bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushAndRemoveUntil(NavigateRoute(widget, type: slideTransitionType),
            (Route<dynamic> route) => false);
    return value;
  }
}

Offset getTransitionOffset(TransitionType type) {
  switch (type) {
    case TransitionType.ltr:
      return Offset(-1.0, 0.0);
    case TransitionType.rtl:
      return Offset(1.0, 0.0);
    case TransitionType.ttb:
      return Offset(0.0, -1.0);
    case TransitionType.btt:
      return Offset(0.0, 1.0);
    case TransitionType.bl:
      return Offset(-1.0, 1.0);
    case TransitionType.br:
      return Offset(1.0, 1.0);
    case TransitionType.tl:
      return Offset(-1.0, -1.0);
    case TransitionType.tr:
      return Offset(1.0, 1.0);
    case TransitionType.scale:
      return Offset(0.6, 1.0);
    default:
      return Offset(1.0, 0.0);
  }
}

class NavigateRoute extends PageRouteBuilder {
  final Widget widget;
  final bool? rootNavigator;
  final TransitionType type;
  NavigateRoute(this.widget, {this.rootNavigator, required this.type})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            if (type == TransitionType.scale) {
              return child;
            }

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
