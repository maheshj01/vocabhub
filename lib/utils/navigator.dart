import 'package:flutter/material.dart';

enum TransitionType {
  // slide
  /// left to right
  ltr,

  /// right to left
  rtl,

  /// top to bottom
  ttb,

  /// bottom to top
  btt,

  /// bottom left
  bl,

  /// bottom right
  br,

  /// top left
  tl,

  /// top right
  tr,

  /// scale
  scale,

  /// fade
  fade,

  /// fade scale
  fadeScale
}

class Navigate<T> {
  /// Replace the top widget with another widget
  static Future<void> pushReplace(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget, type: slideTransitionType));
  }

  static Future<void> push(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,
      TransitionType transitionType = TransitionType.scale}) async {
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget, type: transitionType));
    // return value;
  }

  static Future<void> pushNamed(BuildContext context, String path,
      {bool isDialog = false,
      Object? arguments,
      bool isRootNavigator = true,
      TransitionType transitionType = TransitionType.scale}) async {
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushNamed(path, arguments: arguments);
  }

// pop all Routes except first
  static void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
      Navigator.of(context, rootNavigator: isRootNavigator).popUntil((route) => route.isFirst);

  Future<void> popView(BuildContext context, {T? value, bool isRootNavigator = true}) async =>
      Navigator.of(context, rootNavigator: isRootNavigator).pop(value);

  static Future<void> pushAndPopAll(BuildContext context, Widget widget,
      {bool isRootNavigator = true,
      TransitionType slideTransitionType = TransitionType.scale}) async {
    final value = await Navigator.of(context, rootNavigator: isRootNavigator).pushAndRemoveUntil(
        NavigateRoute(widget, type: slideTransitionType), (Route<dynamic> route) => false);
    return value;
  }
}

Offset getTransitionOffset(TransitionType type) {
  switch (type) {
    case TransitionType.ltr:
      return const Offset(-1.0, 0.0);
    case TransitionType.rtl:
      return const Offset(1.0, 0.0);
    case TransitionType.ttb:
      return const Offset(0.0, -1.0);
    case TransitionType.btt:
      return const Offset(0.0, 1.0);
    case TransitionType.bl:
      return const Offset(-1.0, 1.0);
    case TransitionType.br:
      return const Offset(1.0, 1.0);
    case TransitionType.tl:
      return const Offset(-1.0, -1.0);
    case TransitionType.tr:
      return const Offset(1.0, 1.0);
    case TransitionType.scale:
      return const Offset(0.6, 1.0);
    default:
      return const Offset(0.8, 0.0);
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
            if (type == TransitionType.scale) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: child,
              );
            }
            if (type == TransitionType.fade) {
              return FadeTransition(
                opacity: animation.drive(
                  Tween(begin: 0.0, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: child,
              );
            }
            if (type == TransitionType.fadeScale) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: FadeTransition(
                  opacity: animation.drive(
                    Tween(begin: 0.2, end: 1.0).chain(
                      CurveTween(curve: Curves.ease),
                    ),
                  ),
                  child: child,
                ),
              );
            }

            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          reverseTransitionDuration: const Duration(milliseconds: 100),
        );
}

// class PageRoutes {
//   static const double kDefaultDuration = 0.5;
//   static Route<T> fadeThrough<T>(Widget page,
//       [double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeThroughTransition(
//             animation: animation,
//             secondaryAnimation: secondaryAnimation,
//             child: child);
//       },
//     );
//   }

//   static Route<T> fadeScale<T>(Widget page,
//       [double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeScaleTransition(animation: animation, child: child);
//       },
//     );
//   }

//   static Route<T> sharedAxis<T>(Widget page,
//       [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
//       double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return SharedAxisTransition(
//           animation: animation,
//           secondaryAnimation: secondaryAnimation,
//           transitionType: type,
//           child: child,
//         );
//       },
//     );
//   }
// }
