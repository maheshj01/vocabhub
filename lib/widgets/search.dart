import 'package:flutter/material.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/navbar/search/search.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SearchBuilder extends StatefulWidget {
  final Function(String) onChanged;
  final Function? ontap;
  final bool readOnly;
  final bool autoFocus;
  final Widget suffixIcon;
  final TextEditingController? controller;
  SearchBuilder(
      {Key? key,
      required this.onChanged,
      this.ontap,
      this.controller,
      this.autoFocus = false,
      this.suffixIcon = const SizedBox.shrink(),
      this.readOnly = false})
      : super(key: key);

  @override
  _SearchBuilderState createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      widget.onChanged(searchController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return Container(
        height: 60,
        child: TextField(
          readOnly: widget.readOnly,
          controller: searchController,
          autofocus: widget.autoFocus,
          onTap: () => widget.ontap!(),
          cursorHeight: 24,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              filled: true,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  gapPadding: 0,
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
              hintStyle: TextStyle(color: Colors.black),
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                  tooltip: searchController.text.isNotEmpty ? 'clear' : 'shuffle',
                  icon: searchController.text.isNotEmpty
                      ? Icon(Icons.clear, color: isDark ? Colors.white : VocabTheme.primaryColor)
                      : SizedBox.shrink(),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchController.clear();
                    }
                  }),
              hintText: "Search for a word"),
        ));
  }
}
