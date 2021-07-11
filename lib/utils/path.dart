import 'package:flutter/material.dart';
import 'package:vocabhub/pages/randomplay.dart';

class Path {
  const Path(this.pattern, this.builder);

  final String pattern;
  final Widget Function(BuildContext, String) builder;
}

List<Path> paths = [
  Path(
    '/detail',
    (context, match) => RandomPlay(),
  ),
];

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  for (Path path in paths) {
    final regExpPattern = RegExp(path.pattern);
    if (regExpPattern.hasMatch(settings.name!)) {
      final firstMatch = regExpPattern.firstMatch(settings.name!);
      final match = (firstMatch!.groupCount == 1) ? firstMatch.group(1) : null;
      return MaterialPageRoute<void>(
        builder: (context) => path.builder(context, match!),
        settings: settings,
      );
    } else
      return MaterialPageRoute<void>(
        builder: (context) => path.builder(context, '/detail'),
        settings: settings,
      );
  }
  // If no match is found, [WidgetsApp.onUnknownRoute] handles it.
  return null;
}
