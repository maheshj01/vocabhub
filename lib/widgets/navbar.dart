import 'package:flutter/material.dart';
import 'package:vocabhub/models/navbar_notifier.dart';
import 'package:vocabhub/themes/vocab_theme_data.dart';

class AdaptiveNavBar extends StatefulWidget {
  final bool isDesktop;
  final int index;

  /// defines whether the navabr is hidden or not
  /// This applies only for small screen with bottom navigation bar
  /// For Desktop platforms navbar is always visible
  final bool isHidden;
  final Function(int index)? onChanged;

  const AdaptiveNavBar(
      {Key? key,
      required this.index,
      this.onChanged,
      this.isHidden = false,
      this.isDesktop = false})
      : super(key: key);

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
//   final NavbarNotifier _navbarNotifier = NavbarNotifier();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (!widget.isDesktop) {
      return VocabNavbar(
        _items,
        isHidden: widget.isHidden,
        index: widget.index,
        onItemTapped: (index) => widget.onChanged!(index),
      );
    } else {
      return NavigationRail(
          backgroundColor: VocabThemeData.navbarSurfaceGrey,
          labelType: NavigationRailLabelType.selected,
          trailing: IconButton(
            icon: Icon(Icons.people),
            onPressed: () {},
          ),
          extended: false,
          onDestinationSelected: (x) => widget.onChanged!(x),
          destinations: _items
              .map((e) => NavigationRailDestination(
                  icon: Icon(e.iconData), label: Text(e.text)))
              .toList(),
          selectedIndex: widget.index);
    }
  }
}

/// Bottom navigation bar for mobile/tablets
class VocabNavbar extends StatefulWidget {
  const VocabNavbar(this.menuItems,
      {Key? key,
      required this.onItemTapped,
      required this.index,
      this.isHidden = false})
      : super(key: key);
  final List<MenuItem> menuItems;
  final bool isHidden;
  final int index;
  final Function(int) onItemTapped;

  @override
  _VocabNavbarState createState() => _VocabNavbarState();
}

class _VocabNavbarState extends State<VocabNavbar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant VocabNavbar oldWidget) {
    if (widget.isHidden != isHidden) {
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
              currentIndex: widget.index,
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
