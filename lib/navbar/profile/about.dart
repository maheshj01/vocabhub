import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/widgets/responsive.dart';

class AboutVocabhub extends StatefulWidget {
  static const String route = '/about';

  const AboutVocabhub({
    Key? key,
  }) : super(key: key);

  @override
  State<AboutVocabhub> createState() => _AboutVocabhubState();
}

class _AboutVocabhubState extends State<AboutVocabhub> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => AboutVocabhubDesktop(),
        mobileBuilder: (context) => AboutVocabhubMobile());
  }
}

class AboutVocabhubDesktop extends StatefulWidget {
  const AboutVocabhubDesktop({Key? key}) : super(key: key);

  @override
  State<AboutVocabhubDesktop> createState() => _AboutVocabhubDesktopState();
}

class _AboutVocabhubDesktopState extends State<AboutVocabhubDesktop> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}

class AboutVocabhubMobile extends StatefulWidget {
  const AboutVocabhubMobile({Key? key}) : super(key: key);

  @override
  State<AboutVocabhubMobile> createState() => _AboutVocabhubMobileState();
}

class _AboutVocabhubMobileState extends State<AboutVocabhubMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: 16.0.allPadding,
        child: Column(
          children: [
            /// about the app
            Text(
              '$ABOUT_TEXT',
            ),
            16.0.vSpacer(),
            // open source repo link
            16.0.vSpacer(),
            Expanded(child: SizedBox.shrink()),
            Link(
                uri: Uri.parse(Constants.SOURCE_CODE_URL),
                target: LinkTarget.blank,
                builder: (context, followLink) {
                  return TextButton(
                    onPressed: followLink,
                    child: Text(
                      'Visit Repository',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
            24.0.vSpacer(),
          ],
        ),
      ),
    );
  }
}
