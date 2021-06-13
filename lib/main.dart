import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vocabhub/pages/home.dart';
import 'constants/colors.dart';
import 'constants/constants.dart' show APP_TITLE;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(VocabApp());
}

final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);

class VocabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkNotifier,
        builder: (context, bool isDark, Widget? child) {
          return MaterialApp(
            title: '$APP_TITLE',
            debugShowCheckedModeBanner: !kDebugMode,
            darkTheme: ThemeData.dark(),
            color: primaryColor,
            theme: ThemeData(
              primaryColor: primaryColor,
              iconTheme: IconThemeData(
                  color: darkNotifier.value ? Colors.white : primaryColor),
              cupertinoOverrideTheme: CupertinoThemeData(
                primaryColor: primaryColor,
              ),
              cursorColor: primaryColor,
            ),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(title: '$APP_TITLE'),
          );
        });
  }
}
