import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/widgets.dart';

class DrawerBuilder extends StatefulWidget {
  const DrawerBuilder({Key? key}) : super(key: key);

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
      style: listTitleStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;

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
          Container(
            height: 150,
            alignment: Alignment.center,
            decoration:
                isDark ? null : BoxDecoration(gradient: primaryGradient),
            child: Text('Coming Soon'),
            margin: EdgeInsets.all(0),
          ),
          hLine(),
          ListTile(
            onTap: () {
              launchUrl(REPORT_URL);
            },
            subtitle: subTitle(
              'Report a bug or Request a feature',
            ),
            trailing: trailingIcon(
              Icons.help,
            ),
            title: title(
              'Report',
            ),
          ),
          hLine(),
          ListTile(
            onTap: () {
              launchUrl(SHEET_URL);
            },
            trailing: trailingIcon(
              Icons.insert_drive_file,
            ),
            title: title(
              'Contribute',
            ),
            subtitle: subTitle('Contribute to the excel sheet'),
          ),
          hLine(),
          ListTile(
            subtitle: subTitle('The code to this app is Open Sourced'),
            onTap: () {
              launchUrl(SOURCE_CODE_URL);
            },
            title: title(
              'Github',
            ),
            trailing: Image.asset(
              isDark ? GITHUB_WHITE_ASSET_PATH : GITHUB_ASSET_PATH,
              width: 26,
            ),
          ),
          hLine(),
          Expanded(child: Container()),
          hLine(),
          Container(
            height: 80,
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
                ? const Text('v0.1.0', style: TextStyle(fontSize: 10))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('v', style: const TextStyle(fontSize: 10)),
                      Text(snapshot.data!,
                          style: const TextStyle(fontSize: 10)),
                    ],
                  );
          }),
    ));
  }
}
