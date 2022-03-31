import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/models/navbar_notifier.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/animated_indexed_stack.dart';
import 'package:vocabhub/widgets/navbar.dart';

const appBarDesktopHeight = 128.0;

class BaseHome extends StatefulWidget {
  const BaseHome({Key? key}) : super(key: key);

  @override
  State<BaseHome> createState() => _BaseHomeState();
}

class _BaseHomeState extends State<BaseHome> {
  final _navBarNotifier = NavbarNotifier();

  void _addScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_navBarNotifier.hideBottomNavBar) {
          _navBarNotifier.hideBottomNavBar = false;
        }
      } else {
        if (!_navBarNotifier.hideBottomNavBar) {
          _navBarNotifier.hideBottomNavBar = true;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _addScrollListener();
  }

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    return AnimatedBuilder(
        animation: _navBarNotifier,
        builder: (_, x) {
          final body = SafeArea(
            child: AnimatedIndexedStack(
              index: _navBarNotifier.index,
              children: [
                SelectableText(
                  'starterAppGenericHeadline',
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 20,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int x) {
                      return ListTile(
                        title: Text('item $x'),
                      );
                    }),
                SelectableText(
                  'starterAppGenericHeadline',
                  style: textTheme.bodyText1,
                ),
              ],
            ),
          );
          if (isDesktop) {
            return Row(
              children: [
                AdaptiveNavBar(
                  isDesktop: true,
                  index: _navBarNotifier.index,
                  onChanged: (x) {
                    _navBarNotifier.index = x;
                  },
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Material(
                    child: body,
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              bottomNavigationBar: AdaptiveNavBar(
                isHidden: _navBarNotifier.hideBottomNavBar,
                isDesktop: false,
                onChanged: (x) {
                  _navBarNotifier.index = x;
                },
                index: _navBarNotifier.index,
              ),
              body: body,
            );
          }
        });
  }
}
