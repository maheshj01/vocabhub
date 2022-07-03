import 'package:flutter/material.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';

class UserProfile extends StatelessWidget {
  static const String route = '/';
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => UserProfileDesktop(),
        mobileBuilder: (context) => UserProfileMobile());
  }
}

class UserProfileMobile extends StatelessWidget {
  static const String route = '/';
  const UserProfileMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
            child: user == null || !user.isLoggedIn
                ? VocabButton(
                    onTap: () {
                      Navigate().push(context, AppSignIn());
                    },
                    label: 'Sign In')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome ${user.name}'),
                      SizedBox(
                        height: 20,
                      ),
                      VocabButton(
                        label: 'Sign Out',
                        onTap: () {
                          Settings.clear();
                          Navigate().pushAndPopAll(context, AppSignIn());
                        },
                      )
                    ],
                  )));
  }
}

class UserProfileDesktop extends StatelessWidget {
  static const String route = '/';
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Desktop'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 20,
          itemBuilder: (BuildContext context, int x) {
            return ListTile(
              title: Text('item $x'),
            );
          }),
    );
  }
}
