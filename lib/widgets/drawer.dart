import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/wordscount.dart';

bool isAnimated = false;

class DrawerBuilder extends StatefulWidget {
  final Function(String)? onMenuTap;

  const DrawerBuilder({Key? key, this.onMenuTap}) : super(key: key);

  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {
  Widget subTitle(String text) {
    return Text(
      '$text',
      style: listSubtitleStyle,
    );
  }

  Widget title(String text) {
    return Text(
      '$text',
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  void dispose() {
    isAnimated = true;
    super.dispose();
  }

  Widget _avatar(UserModel user) {
    if (user == null || user.email.isEmpty)
      return CircularAvatar(
        url: '$profileUrl',
        radius: 35,
      );
    else {
      print('${user.name}');
      return CircularAvatar(
        name: getInitial('${user.name}'),
        url: user.avatarUrl,
        radius: 35,
        onTap: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    final userProvider = Provider.of<UserModel>(context);
    Widget trailingIcon(IconData data) {
      return Icon(
        data,
        color: isDark ? Colors.white : Colors.black.withOpacity(0.75),
      );
    }

    return Container(
      decoration: isDark ? null : BoxDecoration(gradient: primaryGradient),
      child: Column(
        children: [
          Consumer<UserModel>(
              builder: (BuildContext _, UserModel? user, Widget? child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              height: 150,
              decoration:
                  isDark ? null : BoxDecoration(gradient: primaryGradient),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _avatar(user!),
                  SizedBox(
                    width: userProvider.isLoggedIn ? 20 : 30,
                  ),
                  Flexible(
                    child: GestureDetector(
                        onTap: () {
                          if (!userProvider.isLoggedIn) {
                            Navigate().popView(context);
                            widget.onMenuTap?.call('Sign In');
                          }
                        },
                        child: Text(
                            userProvider.isLoggedIn
                                ? '${user.name}'
                                : 'Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(fontWeight: FontWeight.w500))),
                  ),
                ],
              ),
            );
          }),
          hLine(),
          ListTile(
            onTap: () {
              launchUrl(REPORT_URL);
            },
            subtitle: subTitle(
              'Report a bug or Request a feature',
            ),
            trailing: trailingIcon(Icons.bug_report),
            title: title(
              'Report',
            ),
          ),
          hLine(),
          ListTile(
            onTap: () {
              Navigate().popView(context);
              Navigate().push(context, AddWordForm(),
                  slideTransitionType: SlideTransitionType.btt);
            },
            trailing: trailingIcon(
              Icons.add,
            ),
            title: title(
              'Add a word',
            ),
            subtitle: subTitle('Can\'t find a word?'),
          ),
          hLine(),
          ListTile(
            subtitle: subTitle('The code to this app is Open Sourced'),
            onTap: () {
              launchUrl(SOURCE_CODE_URL);
            },
            title: title(
              'Source code',
            ),
            trailing: Image.asset(
              isDark ? GITHUB_WHITE_ASSET_PATH : GITHUB_ASSET_PATH,
              width: 26,
            ),
          ),
          hLine(),
          ListTile(
            onTap: () {
              launchUrl(PRIVACY_POLICY);
            },
            trailing: trailingIcon(Icons.privacy_tip),
            title: title(
              'Privacy Policy',
            ),
            subtitle: subTitle(''),
          ),
          hLine(),
          userProvider.isLoggedIn
              ? ListTile(
                  onTap: () {
                    Navigate().popView(context);
                    widget.onMenuTap!('Sign Out');
                  },
                  trailing: trailingIcon(Icons.exit_to_app),
                  title: title(
                    'Sign Out',
                  ),
                  subtitle: subTitle(''),
                )
              : Container(),
          !userProvider.isLoggedIn ? Container() : hLine(),
          Expanded(child: Container()),
          hLine(),
          WordsCountAnimator(
            isAnimated: isAnimated,
          ),
          SizedBox(
            height: 20,
          ),
          if (kIsWeb) storeRedirect(context),
          Container(
            height: 60,
            alignment: Alignment.center,
            child: VersionBuilder(),
          )
        ],
      ),
    );
  }
}

class VersionBuilder extends StatelessWidget {
  final String version;
  const VersionBuilder({Key? key, this.version = ''}) : super(key: key);

  Future<String> getAppDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // + ' (' + packageInfo.buildNumber + ')';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      alignment: Alignment.center,
      child: FutureBuilder<String>(
          future: getAppDetails(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return snapshot.data == null
                ? Text('$VERSION', style: Theme.of(context).textTheme.caption)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('v', style: Theme.of(context).textTheme.caption),
                      Text(snapshot.data!,
                          style: Theme.of(context).textTheme.caption),
                    ],
                  );
          }),
    ));
  }
}
