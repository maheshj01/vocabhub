import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';

class AppSignIn extends ConsumerStatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends ConsumerState<AppSignIn> {
  AuthService auth = AuthService();
  Future<void> _handleSignIn(BuildContext context) async {
    final _userNotifier = ref.read(userNotifierProvider);
    try {
      final token = pushNotificationService.fcmToken;
      _requestNotifier.value = Response(state: RequestState.active);
      user = await auth.googleSignIn(context);
      if (user != null) {
        final existingUser = await UserService.findByEmail(email: user!.email);
        if (existingUser.email.isEmpty) {
          user = user!.copyWith(
            token: token,
          );
          final resp = await AuthService.registerUser(user!);
          if (resp.didSucced) {
            final UserModel registeredUser = UserModel.fromJson((resp.data as List<dynamic>)[0]);
            // state.setUser(user.copyWith(isLoggedIn: true, token: fcmToken));
            registeredUser.loggedIn = true;
            _userNotifier.setUser(registeredUser);
            _requestNotifier.value = Response(state: RequestState.done, data: registeredUser);
            Navigate.pushAndPopAll(context, AdaptiveLayout(), transitionType: TransitionType.ttb);
            firebaseAnalytics.logNewUser(registeredUser);
          } else {
            _userNotifier.loggedIn = false;
            NavbarNotifier.showSnackBar(context, '$signInFailure');
            _requestNotifier.value = Response(state: RequestState.done);
            throw '$registration_Failed';
          }
        } else {
          if (existingUser.isDeleted) {
            _requestNotifier.value = Response(state: RequestState.done);
            NavbarNotifier.showSnackBar(
              context,
              '$accountDeleted ${Constants.FEEDBACK_EMAIL_TO}',
              actionLabel: 'Contact Support',
              showCloseIcon: false,
              duration: Duration(seconds: 10),
              onActionPressed: () => launchURL(
                accountActivationEmail,
              ),
            );
            return;
          }
          existingUser.loggedIn = true;
          _userNotifier.setUser(existingUser);
          user = user!.copyWith(
            token: token,
          );
          await AuthService.updateLogin(
            data: {
              Constants.USER_LOGGEDIN_COLUMN: true,
              Constants.USER_TOKEN_COLUMN: token,
              Constants.DELETED_COLUMN: false
            },
            email: existingUser.email,
          );
          _requestNotifier.value = Response(state: RequestState.done);
          Navigate.pushAndPopAll(context, AdaptiveLayout());
          firebaseAnalytics.logSignIn(user!);
        }
      } else {
        NavbarNotifier.showSnackBar(context, '$signInFailure');
        _requestNotifier.value = Response(state: RequestState.done);
        throw '$registration_Failed';
      }
    } catch (error) {
      NavbarNotifier.showSnackBar(context, bottom: 0, error.toString());
      _requestNotifier.value = Response(state: RequestState.done);
      _userNotifier.loggedIn = false;
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
    firebaseAnalytics = Analytics.instance;
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    Widget _heading(String text) {
      return Text('$text', style: Theme.of(context).textTheme.displaySmall);
    }

    Widget _skipButton() {
      return Align(
          alignment: Alignment.center,
          child: VHButton(
            width: 300,
            foregroundColor: Colors.blue[50],
            label: 'Continue as a Guest',
            onTap: () {
              Navigate.pushReplace(context, AdaptiveLayout(), transitionType: TransitionType.scale);
              // final count = settingsController.skipCount;
              // settingsController.setSkipCount = count;
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
                  foregroundColor: Colors.black,
                  leading: Image.asset('$GOOGLE_ASSET_PATH', height: 32),
                  label: 'Sign In with Google',
                  isLoading: request.state == RequestState.active,
                  onTap: () => _handleSignIn(context),
                  backgroundColor: Colors.white,
                ));
          }

          return IgnorePointer(
              ignoring: request.state == RequestState.active,
              child: ResponsiveBuilder(
                  animate: true,
                  desktopBuilder: (x) {
                    return Row(
                      children: [
                        AnimatedContainer(
                          width: SizeUtils.size.width / 2,
                          duration: Duration(seconds: 1),
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
                        Expanded(
                          child: Container(
                            color: colorScheme.surfaceContainerHighest,
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
                    );
                  },
                  mobileBuilder: (x) {
                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Container(
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
                      ),
                    );
                  }));
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
