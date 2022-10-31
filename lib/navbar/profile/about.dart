import 'package:flutter/material.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/utils/extensions.dart';
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            16.0.vSpacer()
          ],
        ),
      ),
    );
  }
}
