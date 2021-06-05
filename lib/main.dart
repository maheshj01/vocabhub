import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/pages/home.dart';
import 'constants/constants.dart' show APP_TITLE;

void main() {
  runApp(MyApp());
}

final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkNotifier,
        builder: (context, bool isDark, Widget? child) {
          return MaterialApp(
            title: '$APP_TITLE',
            debugShowCheckedModeBanner: kDebugMode,
            darkTheme: ThemeData.dark(),
            theme: ThemeData(primaryColor: Colors.red),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(title: '$APP_TITLE'),
          );
        });
  }
}
