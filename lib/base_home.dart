import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/models/navbar_notifier.dart';
import 'package:vocabhub/navbar/dashboard.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/animated_indexed_stack.dart';
import 'package:vocabhub/widgets/navbar.dart';
import 'package:vocabhub/widgets/widgets.dart';

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
    super.initState();
    _scrollController = ScrollController();
    _addScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((x) {
      init();
    });
  }

  Future<void> init() async {
    showCircularIndicator(context);
    final list = await Future.wait([
      Future.delayed(Duration(seconds: 2), () {
        return Random().nextBool();
      })
    ]);
    setState(() {
      Settings.setIsSignedIn(list[0]);
    });
    stopCircularIndicator(context);
  }

  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;
      final isDesktop = isDisplayDesktop(context);
      Settings.size = Size(constraints.maxWidth, constraints.maxHeight);
      
      return AnimatedBuilder(
          animation: _navBarNotifier,
          builder: (_, x) {
            final body = SafeArea(
              child: AnimatedIndexedStack(
                index: _navBarNotifier.index,
                children: [
                  Dashboard(),
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 20,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int x) {
                        return ListTile(
                          title: Text('item $x'),
                        );
                      }),
                  Center(
                    child: Text(
                      'User Logged in ${Settings.isSignedIn}',
                      style: textTheme.bodyText1,
                    ),
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
                  Expanded(
                    child: Material(
                      child: body,
                    ),
                  ),
                ],
              );
            } else {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.add),
                ),
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
    });
  }
}

class ResponsiveBuilder extends StatefulWidget {
  final WidgetBuilder desktopBuilder;
  final WidgetBuilder mobileBuilder;

  const ResponsiveBuilder(
      {Key? key, required this.desktopBuilder, required this.mobileBuilder})
      : super(key: key);

  @override
  State<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends State<ResponsiveBuilder> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      if (constrains.maxWidth > 600) {
        return widget.desktopBuilder(context);
      }
      return widget.mobileBuilder(context);
    });
  }
}
