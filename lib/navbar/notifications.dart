import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  static const String route = '/notifications';
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: Center(
          child: Text('Notifications'),
        ));
  }
}
