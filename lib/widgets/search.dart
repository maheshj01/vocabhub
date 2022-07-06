import 'package:flutter/material.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SearchBuilder extends StatefulWidget {
  final Function(String) onChanged;
  final Function? ontap;
  SearchBuilder({Key? key, required this.onChanged, this.ontap})
      : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      widget.onChanged(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: searchController,
          autofocus: false,
          onTap: () => widget.ontap!(),
          cursorHeight: 24,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              filled: true,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  gapPadding: 0,
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2))),
              hintStyle: TextStyle(color: Colors.black),
              suffixIcon: IconButton(
                  tooltip:
                      searchController.text.isNotEmpty ? 'clear' : 'shuffle',
                  icon: searchController.text.isNotEmpty
                      ? Icon(Icons.clear,
                          color:
                              isDark ? Colors.white : VocabTheme.primaryColor)
                      : SizedBox.shrink(),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchController.clear();
                    }
                  }),
              hintText: "Search "),
        ));
  }
}
