import 'package:flutter/material.dart';

class SearchBuilder extends StatefulWidget {
  const SearchBuilder({Key? key}) : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          onChanged: (x) {
            setState(() {});
          },
          decoration: InputDecoration(hintText: "Search Word"),
        ));
  }
}
