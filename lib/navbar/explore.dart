import 'package:flutter/material.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class ExploreWords extends StatefulWidget {
  static const String route = '/';
  const ExploreWords({Key? key}) : super(key: key);

  @override
  State<ExploreWords> createState() => _ExploreWordsState();
}

class _ExploreWordsState extends State<ExploreWords> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ExploreWordsDesktop(),
        mobileBuilder: (context) => ExploreWordsMobile());
  }
}

class ExploreWordsMobile extends StatelessWidget {
  const ExploreWordsMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final words = AppStateScope.of(context).words;
    if (words == null || words.isEmpty) return SizedBox.shrink();
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
              itemCount: words.length,
              scrollBehavior: MaterialScrollBehavior(),
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return WordDetail(word: words[index]);
              }),
        ],
      ),
    );
  }
}

class ExploreWordsDesktop extends StatelessWidget {
  const ExploreWordsDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Desktop'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 20,
          itemBuilder: (BuildContext context, int x) {
            return ListTile(
              title: Text('item $x'),
            );
          }),
    );
  }
}
