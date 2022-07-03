import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/size_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
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
    final user = Provider.of<UserModel>(context, listen: false);
    final bool signedIn = await Settings.isSignedIn;
    final String _email = await Settings.email;
    final int count = await Settings.skipCount + 1;
    user.email = _email;
    if (signedIn && _email.isNotEmpty) {
      user.isLoggedIn = true;
      Navigate().push(context, AdaptiveLayout());
    } else {
      user.isLoggedIn = false;
      if (count % 3 != 0) {
        Settings.setSkipCount = count;
        Navigate().push(context, AdaptiveLayout());
      } else {
        Navigate().push(context, AppSignIn());
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
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
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
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(color: Colors.grey)),
                ),
                Text('Vocabhub', style: Theme.of(context).textTheme.headline2),
              ],
            )),
      ),
    );
  }
}
