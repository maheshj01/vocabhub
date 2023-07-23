import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/size_utils.dart';

import '../onboarding/welcome.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
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
        if (!SizeUtils.isMobile && kIsWeb) {
          handleNavigation();
        } else {
          if (settingsController.isOnboarded && SizeUtils.isMobile) {
            handleNavigation();
          } else {
            Navigate.pushReplace(
                context,
                WelcomePage(
                  title: 'Welcome to VocabHub',
                  description: 'Your companion to learn new words everyday',
                ));
          }
        }
      }
    });
  }

  Future<void> handleNavigation() async {
    final user = ref.watch(userNotifierProvider);
    final String _email = user.email;
    if (_email.isNotEmpty && user.isLoggedIn) {
      Navigate.pushReplace(context, AdaptiveLayout());
    } else {
      final int count = settingsController.skipCount + 1;
      settingsController.setSkipCount = count;
      if (count % 3 != 0) {
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            colorScheme.primary,
            colorScheme.secondary,
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
                  child: Text(Constants.APP_TITLE,
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.grey)),
                ),
                Text(Constants.APP_TITLE,
                    style:
                        Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.white)),
              ],
            )),
      ),
    );
  }
}
