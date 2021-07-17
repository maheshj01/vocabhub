import 'package:flutter/material.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart';
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
      widget.onChanged(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    Size size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: size.width > MOBILE_WIDTH
            ? null
            : BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black : Colors.grey.withOpacity(.5),
                    blurRadius: 16.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: Offset(
                      5.0, // Move to right 10  horizontally
                      5.0, // Move to bottom 10 Vertically
                    ),
                  )
                ],
                borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          children: [
            size.width < MOBILE_WIDTH
                ? IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.menu),
                  )
                : Container(),
            SizedBox(
              width: size.width < MOBILE_WIDTH ? 8 : 0,
            ),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: isDark ? Colors.white : primaryColor),
                            onPressed: () {
                              searchController.clear();
                            })
                        : SizedBox(width: 1),
                    hintText: "Search "),
              ),
            ),
            SizedBox(
              width: size.width > MOBILE_WIDTH ? 8 : 0,
            ),
          ],
        ));
  }
}
