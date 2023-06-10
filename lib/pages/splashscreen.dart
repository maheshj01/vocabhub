import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/size_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );

  late final Animation<double> _animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceIn,
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        handleNavigation();
      }
    });
  }

  Future<void> handleNavigation() async {
    UserModel? user = AppStateScope.of(context).user;
    final String _email = await Settings.email;
    final int count = await Settings.skipCount + 1;
    if (user == null) {
      user = UserModel.init();
    }
    user.email = _email;
    if (_email.isNotEmpty) {
      user.isLoggedIn = true;
      AppStateWidget.of(context).setUser(user);
      Navigate.pushReplace(context, AdaptiveLayout());
    } else {
      user.isLoggedIn = false;
      AppStateWidget.of(context).setUser(user);
      if (count % 3 != 0) {
        Settings.setSkipCount = count;
        Navigate.pushReplace(context, AdaptiveLayout());
      } else {
        Navigate.pushReplace(context, AppSignIn());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            VocabTheme.primaryColor.withOpacity(0.5),
            VocabTheme.secondaryColor,
          ]),
        ),
        alignment: Alignment.center,
        child: FadeScaleTransition(
            animation: _animation,
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 2,
                  child: Text('Vocabhub',
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.grey)),
                ),
                Text('Vocabhub',
                    style:
                        Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.white)),
              ],
            )),
      ),
    );
  }
}
