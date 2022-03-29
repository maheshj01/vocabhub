import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/themes/vocab_theme_data.dart';
import 'package:vocabhub/utils/utility.dart';

const appBarDesktopHeight = 128.0;

class BaseHome extends StatefulWidget {
  const BaseHome({Key? key}) : super(key: key);

  @override
  State<BaseHome> createState() => _BaseHomeState();
}

class _BaseHomeState extends State<BaseHome> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);
    final body = SafeArea(
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'starterAppGenericHeadline',
            ),
            const SizedBox(height: 10),
            SelectableText(
              'starterAppGenericHeadline',
              style: textTheme.subtitle1,
            ),
            const SizedBox(height: 48),
            SelectableText(
              'starterAppGenericHeadline',
              style: textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          AdaptiveNavBar(
            isDesktop: true,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              body: body,
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'Extended Add',
                onPressed: () {},
                label: Text(
                  'App Generic button',
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                icon: Icon(Icons.add, color: colorScheme.onSecondary),
              ),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        bottomNavigationBar: AdaptiveNavBar(),
        body: body,
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

class AdaptiveNavBar extends StatefulWidget {
  final bool isDesktop;
  const AdaptiveNavBar({Key? key, this.isDesktop = false}) : super(key: key);

  @override
  _AdaptiveNavBarState createState() => _AdaptiveNavBarState();
}

class _AdaptiveNavBarState extends State<AdaptiveNavBar> {
  static const numItems = 9;
  List<MenuItem> _items = [
    MenuItem(Icons.dashboard, 'Dashboard'),
    MenuItem(Icons.bookmark, 'Bookmarks'),
    MenuItem(Icons.person, 'Profile'),
  ];
  int selectedItem = 0;
  final NavbarNotifier _navbarNotifier = NavbarNotifier();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
        animation: _navbarNotifier,
        builder: (context, child) {
          if (!widget.isDesktop) {
            return VocabNavbar(
              _navbarNotifier,
              _items,
              onItemTapped: (index) {
                _navbarNotifier.index = index;
              },
            );
          } else {
            return NavigationRail(
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    IconButton(
                      icon: Icon(Icons.people),
                      onPressed: () {},
                    ),
                  ],
                ),
                extended: widget.isDesktop,
                onDestinationSelected: (x) {
                  _navbarNotifier.index = x;
                },
                destinations: _items
                    .map((e) => NavigationRailDestination(
                        icon: Icon(e.iconData), label: Text(e.text)))
                    .toList(),
                selectedIndex: _navbarNotifier.index);
          }
        });
  }
}

/// Bottom navigation bar for small screens
class VocabNavbar extends StatefulWidget {
  const VocabNavbar(this.model, this.menuItems,
      {Key? key, required this.onItemTapped})
      : super(key: key);
  final List<MenuItem> menuItems;
  final NavbarNotifier model;
  final Function(int) onItemTapped;

  @override
  _VocabNavbarState createState() => _VocabNavbarState();
}

class _VocabNavbarState extends State<VocabNavbar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant VocabNavbar oldWidget) {
    if (widget.model.hideBottomNavBar != isHidden) {
      if (!isHidden) {
        _showBottomNavBar();
      } else {
        _hideBottomNavBar();
      }
      isHidden = !isHidden;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _hideBottomNavBar() {
    _controller.reverse();
    return;
  }

  void _showBottomNavBar() {
    _controller.forward();
    return;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() => setState(() {}));
    animation = Tween(begin: 0.0, end: 100.0).animate(_controller);
  }

  late AnimationController _controller;
  late Animation<double> animation;
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: widget.model.index,
              selectedItemColor: VocabThemeData.primaryGreen,
              onTap: (x) => widget.onItemTapped(x),
              showUnselectedLabels: true,
              unselectedItemColor: Colors.black,
              backgroundColor: VocabThemeData.navbarSurfaceGrey,
              items: widget.menuItems
                  .map((MenuItem menuItem) => BottomNavigationBarItem(
                        icon: Icon(menuItem.iconData),
                        label: menuItem.text,
                      ))
                  .toList(),
            ),
          );
        });
  }
}

class MenuItem {
  const MenuItem(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

class NavbarNotifier extends ChangeNotifier {
  int _index = 0;
  int _last = 0;
  bool _shouldReload = false;
  bool _hideBottomNavBar = false;
  int _categoryIndex = 0;
  List<int> _indexList = [];

  /// while toggling the tabs programatically
  /// update [shouldReload] to whether or not to fetch the updated Data from the network
  bool get shouldReload => _shouldReload;

  void remove() {
    _indexList.removeLast();
    notifyListeners();
  }

  void add(int x) {
    _indexList.add(x);
    notifyListeners();
  }

  int get top => _indexList.last;

  int get length => _indexList.length;

  int get index => _index;
  set index(int x) {
    _index = x;
    notifyListeners();
  }

  int get categoryIndex => _categoryIndex;
  set categoryIndex(int x) {
    _categoryIndex = x;
    notifyListeners();
  }

  set shouldReload(bool x) {
    _shouldReload = x;
    notifyListeners();
  }

  bool get hideBottomNavBar => _hideBottomNavBar;
  set hideBottomNavBar(bool x) {
    _hideBottomNavBar = x;
    notifyListeners();
  }
}

class AnimatedIndexedStack extends StatefulWidget {
  const AnimatedIndexedStack({
    Key? key,
    required this.index,
    required this.children,
  }) : super(key: key);

  /// selected Index
  final int index;

  /// List of menu items
  final List<Widget> children;

  @override
  _AnimatedIndexedStackState createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _index;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _index = widget.index;
    _controller.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _index) {
      _controller.reverse().then((_) {
        setState(() => _index = widget.index);
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _controller,
          child: Transform.scale(
            scale: 1.010 - (_controller.value * .010),
            child: child,
          ),
        );
      },
      child: IndexedStack(
        index: _index,
        children: widget.children,
      ),
    );
  }
}

/// Currently not in use
/// Wrapper around fadethrough animation
class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.child,
  });

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?>? onClosed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return child;
      },
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}
