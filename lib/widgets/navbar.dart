import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/navbar_notifier.dart' as menu;
import 'package:vocabhub/themes/vocab_theme_data.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';

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

  List<menu.MenuItem> _items = [
    menu.MenuItem(Icons.dashboard, 'Dashboard'),
    menu.MenuItem(Icons.perm_contact_cal_rounded, 'Practice'),
    menu.MenuItem(Icons.person, 'Profile'),
  ];
  int selectedItem = 0;

  Widget _userAvatar() {
    return Consumer<UserModel>(
        builder: (BuildContext _, UserModel? user, Widget? child) {
      if (user == null || user.email.isEmpty)
        return CircularAvatar(
          url: '$profileUrl',
          radius: 25,
        );
      else {
        return CircularAvatar(
          name: getInitial('${user.name}'),
          url: user.avatarUrl,
          radius: 25,
          onTap: null,
        );
      }
    });
  }

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
          backgroundColor: VocabTheme.navbarSurfaceGrey,
          labelType: NavigationRailLabelType.selected,
          trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _userAvatar(),
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
  final List<menu.MenuItem> menuItems;
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
              selectedItemColor: VocabTheme.primaryGreen,
              onTap: (x) => widget.onItemTapped(x),
              showUnselectedLabels: true,
              unselectedItemColor: Colors.black,
              backgroundColor: VocabTheme.navbarSurfaceGrey,
              items: widget.menuItems
                  .map((menu.MenuItem menuItem) => BottomNavigationBarItem(
                        icon: Icon(menuItem.iconData),
                        label: menuItem.text,
                      ))
                  .toList(),
            ),
          );
        });
  }
}
