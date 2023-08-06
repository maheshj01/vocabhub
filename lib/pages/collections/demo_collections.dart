import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/widgets.dart';

class DemoCollections extends ConsumerStatefulWidget {
  static const route = '/collections/demo';
  const DemoCollections({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DemoCollectionsState();
}

class _DemoCollectionsState extends ConsumerState<DemoCollections> {
  Widget collectionTile(String title, IconData iconData) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: 8.0.horizontalPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '$title',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.titleMedium!.copyWith(color: colorScheme.secondary),
            ),
          ),
          16.0.hSpacer(),
          Icon(iconData, size: 30, color: colorScheme.primary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: 32.0.verticalPadding,
          child: heading('How collections work', color: colorScheme.primary),
        ),
        Expanded(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              collectionTile(
                  'Collections are a way to organize your words.', Icons.collections_bookmark),
              Container(
                  alignment: Alignment.centerRight,
                  margin: 22.0.rightPadding,
                  child: vLine(color: colorScheme.primary, height: 32, width: 2.0)),
              collectionTile('You can create a collection and add words to it.',
                  Icons.add_circle_outline_outlined),
              Container(
                  alignment: Alignment.centerRight,
                  margin: 22.0.rightPadding,
                  child: vLine(color: colorScheme.primary, height: 32, width: 2.0)),
              collectionTile('You can view your collections on your profile page.', Icons.person),
              Container(
                  alignment: Alignment.centerRight,
                  margin: 22.0.rightPadding,
                  child: vLine(color: colorScheme.primary, height: 32, width: 2.0)),
              collectionTile(
                  'Pin/unpin collections to/from your Dashboard for quick access', Icons.push_pin),
              48.0.vSpacer(),
              Padding(
                padding: 16.0.horizontalPadding,
                child: Text("$onDeviceCollectionsString2",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
