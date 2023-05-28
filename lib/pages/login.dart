import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';

class AppSignIn extends StatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends State<AppSignIn> {
  AuthService auth = AuthService();

  Future<void> _handleSignIn(BuildContext context) async {
    final state = AppStateWidget.of(context);
    try {
      _requestNotifier.value = Response(state: RequestState.active);
      user = await auth.googleSignIn(context);
      final fcmToken = pushNotificationService.fcmToken;
      print("FirebaseMessaging token: $fcmToken");
      if (user != null) {
        final existingUser = await UserService.findByEmail(email: user!.email);
        if (existingUser.email.isEmpty) {
          final resp = await AuthService.registerUser(user!);
          if (resp.didSucced) {
            final user = UserModel.fromJson((resp.data as List<dynamic>)[0]);
            state.setUser(user.copyWith(isLoggedIn: true, token: fcmToken));
            _requestNotifier.value = Response(state: RequestState.done);
            Navigate.pushAndPopAll(context, AdaptiveLayout(),
                slideTransitionType: TransitionType.ttb);
            await Settings.setIsSignedIn(true, email: user.email);
            firebaseAnalytics.logNewUser(user);
          } else {
            await Settings.setIsSignedIn(false, email: existingUser.email);
            showMessage(context, '$signInFailure');
            _requestNotifier.value = Response(state: RequestState.done);
            throw 'failed to register new user';
          }
        } else {
          await Settings.setIsSignedIn(true, email: existingUser.email);
          if (!kIsWeb) {
            await AuthService.updateTokenOnLogin(email: existingUser.email, token: fcmToken!);
          }
          state.setUser(existingUser.copyWith(isLoggedIn: true, token: fcmToken));
          _requestNotifier.value = Response(state: RequestState.done);
          Navigate.pushAndPopAll(context, AdaptiveLayout());
          firebaseAnalytics.logSignIn(user!);
        }
      } else {
        showMessage(context, '$signInFailure');
        _requestNotifier.value = Response(state: RequestState.done);
        throw 'failed to register new user';
      }
    } catch (error) {
      showMessage(context, error.toString());
      _requestNotifier.value = Response(state: RequestState.done);
      await Settings.setIsSignedIn(false);
    }
  }

  UserModel? user;
  late Analytics firebaseAnalytics;
  final ValueNotifier<Response> _requestNotifier =
      ValueNotifier<Response>(Response(state: RequestState.none));
  @override
  void dispose() {
    _requestNotifier.dispose();
    super.dispose();
  }

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
        style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white),
      );
    }

    Widget _skipButton() {
      return Align(
          alignment: Alignment.center,
          child: VHButton(
            width: 300,
            backgroundColor: VocabTheme.primaryColor,
            foregroundColor: Colors.white,
            label: 'Continue as a Guest',
            onTap: () {
              Navigate.pushReplace(context, AdaptiveLayout(),
                  slideTransitionType: TransitionType.scale);
              Settings.setSkipCount = Settings.maxSkipCount;
            }, // _handleSignIn(context),
          ));
    }

    return ValueListenableBuilder<Response>(
        valueListenable: _requestNotifier,
        builder: (BuildContext context, Response request, Widget? child) {
          Widget _signInButton() {
            return Align(
                alignment: Alignment.center,
                child: VHButton(
                  width: 300,
                  leading: Image.asset('$GOOGLE_ASSET_PATH', height: 32),
                  label: 'Sign In with Google',
                  isLoading: request.state == RequestState.active,
                  onTap: () => _handleSignIn(context),
                  backgroundColor: Colors.white,
                ));
          }

          return IgnorePointer(
            ignoring: request.state == RequestState.active,
            child: Scaffold(
                backgroundColor:
                    darkNotifier.value ? VocabTheme.surfaceGrey : VocabTheme.surfaceGreen,
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          200.0.vSpacer(),
                          // _heading('Hi!'),
                          _heading('Welcome!'),
                          Expanded(child: Container()),
                          _signInButton(),

                          20.0.vSpacer(),
                          _skipButton(),
                          Expanded(child: Container()),

                          100.0.vSpacer(),
                        ]),
                      )),
          );
        });
  }
}

class ImageBackground extends StatelessWidget {
  final Widget child;
  final String? imageSrc;
  const ImageBackground({Key? key, required this.child, this.imageSrc}) : super(key: key);

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
