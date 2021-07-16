import 'package:flutter/material.dart';
import 'package:vocabhub/exports.dart';

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

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(0.0, -50.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceIn,
  ));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.5),
                secondaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: SlideTransition(
            position: _offsetAnimation,
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
