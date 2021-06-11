import 'package:flutter/material.dart';
import 'package:vocabhub/pages/home.dart';

class SearchBuilder extends StatefulWidget {
  final Function(String) onChanged;

  const SearchBuilder({Key? key, required this.onChanged}) : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController.addListener(() {
      setState(() {});
      widget.onChanged(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                      })
                  : SizedBox(width: 1),
              hintText: "Search by word, meaning"),
        ));
  }
}
