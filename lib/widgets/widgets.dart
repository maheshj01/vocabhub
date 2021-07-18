import 'package:flutter/material.dart';
import 'package:vocabhub/constants/colors.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/utils/utility.dart';

void removeFocus(BuildContext context) => FocusScope.of(context).unfocus();

void showCircularIndicator(BuildContext context, {Color? color}) {
  removeFocus(context);
  showDialog<void>(
      barrierColor: color,
      context: context,
      barrierDismissible: false,
      builder: (x) => LoadingWidget());
}

void stopCircularIndicator(BuildContext context) {
  Navigator.of(context).pop();
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: primaryGreen,
    ));
  }
}

Widget hLine({Color? color}) {
  return Container(
    height: 0.4,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

Widget vLine({Color? color}) {
  return Container(
    width: 0.4,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

RichText buildExample(String example, String word) {
  final textSpans = [TextSpan(text: ' - ')];
  final iterable = example
      .split(' ')
      .toList()
      .map((e) => TextSpan(
          text: e + ' ',
          style: TextStyle(
              fontWeight: (e.toLowerCase().contains(word.toLowerCase()))
                  ? FontWeight.bold
                  : FontWeight.normal)))
      .toList();
  textSpans.addAll(iterable);
  textSpans.add(TextSpan(text: '\n'));
  return RichText(
      text: TextSpan(
          style: TextStyle(
              color: darkNotifier.value ? Colors.white : Colors.black),
          children: textSpans));
}

Widget playStoreRedirect(BuildContext context) {
  return GestureDetector(
    onTap: () {
      final firebaseAnalytics = Analytics();
      final width = MediaQuery.of(context).size.width;
      firebaseAnalytics
          .logRedirectToStore(width > MOBILE_WIDTH ? 'desktop' : 'mobile');
      launchUrl(PLAY_STORE_URL);
    },
    child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset('assets/googleplay.png', height: 50)),
  );
}
