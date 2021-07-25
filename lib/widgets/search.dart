import 'package:flutter/material.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/home.dart';

class SearchBuilder extends StatefulWidget {
  final Function(String) onChanged;
  final Function() onShuffle;

  const SearchBuilder(
      {Key? key, required this.onChanged, required this.onShuffle})
      : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchController.addListener(() {
      widget.onChanged(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: searchController,
          autofocus: false,
          decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: isDark ? Colors.white : primaryColor),
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                      searchController.text.isNotEmpty
                          ? Icons.clear
                          : Icons.shuffle,
                      color: isDark ? Colors.white : primaryColor),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchController.clear();
                    } else {
                      widget.onShuffle();
                    }
                  }),
              hintText: "Search "),
        ));
  }
}
