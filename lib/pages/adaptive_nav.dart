import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';

class AdaptiveView extends StatefulWidget {
  const AdaptiveView({Key? key}) : super(key: key);

  @override
  _AdaptiveViewState createState() => _AdaptiveViewState();
}

class _AdaptiveViewState extends State<AdaptiveView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    final _navigationDestinations = <Destination>[
      Destination(
        textLabel: 'Add word',
        iconData: Icons.add,
      ),
    ];
    final body = SafeArea(
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Head1',
              style: textTheme.headline3!.copyWith(
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Title2',
              style: textTheme.subtitle1,
            ),
            const SizedBox(height: 48),
            Text(
              'Title3',
              style: textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          DrawerBuilder(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: const AdaptiveAppBar(
                isDesktop: true,
              ),
              body: body,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: const AdaptiveAppBar(),
        body: body,
        drawer: const DrawerBuilder(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'Add',
          onPressed: () {},
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      );
    }
  }
}

class Destination {
  const Destination({
    required this.textLabel,
    required this.iconData,
    this.subtitle,
  });

  final String textLabel;
  final String? subtitle;
  final IconData iconData;
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    Key? key,
    this.isDesktop = false,
  }) : super(key: key);

  final bool isDesktop;

  @override
  Size get preferredSize => isDesktop
      ? const Size.fromHeight(appBarDesktopHeight)
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: !isDesktop,
      title: isDesktop ? null : Text('$APP_TITLE'),
      backgroundColor: Colors.blue,
      bottom: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(26),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                margin: const EdgeInsetsDirectional.fromSTEB(72, 0, 0, 22),
                child: Text(
                  '$APP_TITLE',
                  style: themeData.textTheme.headline6!.copyWith(
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }
}
