import 'package:flutter/material.dart';

class RandomPlay extends StatefulWidget {
  const RandomPlay({Key? key}) : super(key: key);

  @override
  _RandomPlayState createState() => _RandomPlayState();
}

class _RandomPlayState extends State<RandomPlay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Random Word'),
      ),
    );
  }
}
