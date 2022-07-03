import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/auth.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';

class AppSignIn extends StatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends State<AppSignIn> {
  Authentication auth = Authentication();

  Future<void> _handleSignIn(BuildContext context) async {
    final userProvider = Provider.of<UserModel>(context, listen: false);
    try {
      user = await auth.googleSignIn(context);
      if (user != null) {
        final existingUser = await UserStore().findByEmail(email: user!.email);
        if (existingUser == null) {
          logger.d('registering new user ${user!.email}');
          final isRegistered = await _register(user!);
          if (isRegistered) {
            userProvider.user = user!;
            await Settings.setIsSignedIn(true, email: user!.email);
            Navigate().pushAndPopAll(context, AdaptiveLayout(),
                slideTransitionType: TransitionType.ttb);
          } else {
            logger.d('failed to sign in User');
            await Settings.setIsSignedIn(false, email: existingUser!.email);
            showMessage(context, 'User Not registered');
            throw 'failed to register new user';
          }
        } else {
          logger.d('found existing user ${user!.email}');
          userProvider.user = user!;
          await Settings.setIsSignedIn(true, email: existingUser.email);
          Navigate().pushAndPopAll(context, AdaptiveLayout(),
              slideTransitionType: TransitionType.ttb);
          firebaseAnalytics.logSignIn(user!);
        }
      } else {
        throw 'User null';
      }
    } catch (error) {
      logger.e(error);
      await Settings.setIsSignedIn(false);
    }
  }

  Future<bool> _register(UserModel newUser) async {
    try {
      final resp = await UserStore().registerUser(newUser);
      if (resp.didSucced) {
        firebaseAnalytics.logNewUser(newUser);
        return true;
      } else
        return false;
    } catch (error) {
      print(error);
      await Settings.setIsSignedIn(false);
      return false;
    }
  }

  UserModel? user;
  late Analytics firebaseAnalytics;

  @override
  void initState() {
    super.initState();
    firebaseAnalytics = Analytics();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;

    Widget _heading(String text) {
      return Text(
        '$text',
        style: Theme.of(context)
            .textTheme
            .headline3!
            .copyWith(color: Colors.white),
      );
    }

    Widget _signInButton() {
      return Align(
          alignment: Alignment.center,
          child: VocabButton(
            width: 300,
            leading: Image.asset('$GOOGLE_ASSET_PATH', height: 32),
            label: 'Sign In with Google',
            onTap: () => _handleSignIn(context),
            backgroundColor: Colors.white,
          ));
    }

    Widget _skipButton() {
      return Align(
          alignment: Alignment.center,
          child: VocabButton(
            width: 300,
            backgroundColor: VocabTheme.primaryColor,
            foregroundColor: Colors.white,
            label: 'Continue as a Guest',
            onTap: () {
              Navigate().pushReplace(context, AdaptiveLayout(),
                  slideTransitionType: TransitionType.scale);
              Settings.setSkipCount = Settings.maxSkipCount;
            }, // _handleSignIn(context),
          ));
    }

    return Scaffold(
        backgroundColor: darkNotifier.value
            ? VocabTheme.surfaceGrey
            : VocabTheme.surfaceGreen,
        body: !SizeUtils.isMobile
            ? Row(
                children: [
                  AnimatedContainer(
                    width: SizeUtils.size.width / 2,
                    duration: Duration(seconds: 1),
                    child: ImageBackground(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _heading('Hi!'),
                            _heading('Welcome Back.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Spacer(),
                          _signInButton(),
                          SizedBox(
                            height: 20,
                          ),
                          _skipButton(),
                          Spacer()
                        ],
                      ),
                    ),
                  )
                ],
              )
            : ImageBackground(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                      ),
                      // _heading('Hi!'),
                      _heading('Welcome!'),
                      Expanded(child: Container()),
                      _signInButton(),
                      SizedBox(
                        height: 20,
                      ),
                      _skipButton(),
                      Expanded(child: Container()),
                      SizedBox(
                        height: 100,
                      )
                    ]),
              ));
  }
}

class ImageBackground extends StatelessWidget {
  final Widget child;
  final String? imageSrc;
  const ImageBackground({Key? key, required this.child, this.imageSrc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageSrc ?? '$WALLPAPER_1'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
