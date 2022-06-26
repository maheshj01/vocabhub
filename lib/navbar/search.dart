import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  static String route = '/';
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(),
      ),
      body: Center(
        child: Text('Search Words'),
      ),
    );
  }
}
