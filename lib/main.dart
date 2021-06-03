import 'package:flutter/material.dart';
import 'package:flutter_template/pages/home.dart';
import 'constants/constants.dart' show APP_TITLE;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$APP_TITLE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Template'),
    );
  }
}
