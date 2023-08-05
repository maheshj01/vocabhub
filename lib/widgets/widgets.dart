import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/size_utils.dart';
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
  final Color? color;
  const LoadingWidget({Key? key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

Widget hLine({Color? color, double height = 0.4}) {
  return Container(
    height: height,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

Widget vLine({Color? color}) {
  return Container(
    width: 0.4,
    color: color ?? Colors.grey.withOpacity(0.5),
  );
}

SelectableText buildExample(String example, String word, {TextStyle? style}) {
  final textSpans = [TextSpan(text: ' - ')];
  final iterable = example
      .split(' ')
      .toList()
      .map((e) => TextSpan(
          text: '$e ',
          style: style ??
              TextStyle(
                  fontWeight: (e.toLowerCase().contains(word.toLowerCase()))
                      ? FontWeight.bold
                      : FontWeight.normal)))
      .toList();
  textSpans.addAll(iterable);
  textSpans.add(TextSpan(text: '\n'));
  return SelectableText.rich(TextSpan(children: textSpans));
}

Widget storeRedirect(BuildContext context,
    {String redirectUrl = Constants.PLAY_STORE_URL, String assetUrl = 'assets/googleplay.png'}) {
  return GestureDetector(
    onTap: () {
      final firebaseAnalytics = Analytics.instance;
      final width = MediaQuery.of(context).size.width;
      firebaseAnalytics
          .logRedirectToStore(width > SizeUtils.kTabletBreakPoint ? 'desktop' : 'mobile');
      launchURL(redirectUrl);
    },
    child:
        MouseRegion(cursor: SystemMouseCursors.click, child: Image.asset('$assetUrl', height: 50)),
  );
}

RichText buildNotification(String notification, String word, {TextStyle? style}) {
  final List<InlineSpan>? textSpans = [];
  final iterable = notification.split(' ').toList().map((e) {
    final isMatched = e.toLowerCase().contains(word.toLowerCase());
    return TextSpan(
        text: '$e ',
        style: style ??
            TextStyle(fontSize: 16, fontWeight: isMatched ? FontWeight.bold : FontWeight.w400));
  }).toList();
  textSpans!.addAll(iterable);
  return RichText(text: TextSpan(text: '', children: textSpans));
}

Widget heading(String title, {double fontSize: 20}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    ),
  );
}

RichText differenceVisualizerByWord(String editedText, String oldText,
    {bool isOldVersion = true, TextAlign textAlign = TextAlign.start}) {
  final oldTextList = oldText.split(' ');
  final newTextList = editedText.split(' ');
  final oldTextLength = oldTextList.length;
  final newTextLength = newTextList.length;
  final minLengthList = min(newTextLength, oldTextLength);

  return RichText(
    textAlign: textAlign,
    text: TextSpan(
      style: TextStyle(
        fontSize: 16.0,
        color: settingsController.isDark ? Colors.white : Colors.black,
      ),
      children: <TextSpan>[
        for (int i = 0; i < minLengthList; i++)
          if (oldTextList[i] == newTextList[i])
            TextSpan(text: '${newTextList[i]} ')
          else
            TextSpan(
                text: isOldVersion ? '${oldTextList[i]} ' : '${newTextList[i]} ',
                style: TextStyle(
                  color: isOldVersion ? Colors.red : Colors.green,
                  decoration: isOldVersion ? TextDecoration.lineThrough : null,
                )),
        if (oldTextLength > newTextLength && isOldVersion)
          for (int i = minLengthList; i < oldTextLength; i++)
            TextSpan(
                text: '${oldTextList[i]} ',
                style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                )),
        if (newTextLength > oldTextLength && !isOldVersion)
          for (int i = minLengthList; i < newTextLength; i++)
            TextSpan(text: '${newTextList[i]} ', style: TextStyle(color: Colors.green)),
      ],
    ),
  );
}

RichText differenceVisualizerGranular(String editedText, String oldText,
    {bool isOldVersion = true, TextAlign textAlign = TextAlign.start}) {
  final oldTextLength = oldText.length;
  final newTextLength = editedText.length;
  final minLength = min(newTextLength, oldTextLength);
  return RichText(
    textAlign: textAlign,
    text: TextSpan(
      style: TextStyle(
        fontSize: 14.0,
        color: settingsController.isDark ? Colors.white : Colors.black,
      ),
      children: <TextSpan>[
        for (int i = 0; i < minLength; i++)
          if (oldText[i] == editedText[i])
            TextSpan(text: editedText[i])
          else
            TextSpan(
                text: isOldVersion ? oldText[i] : editedText[i],
                style: TextStyle(
                  decoration: isOldVersion ? TextDecoration.lineThrough : null,
                  backgroundColor: isOldVersion ? Colors.red : Colors.green,
                )),
        if (oldTextLength > newTextLength && isOldVersion)
          for (int i = minLength; i < oldTextLength; i++)
            TextSpan(
                text: oldText[i],
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  backgroundColor: Colors.red,
                )),
        if (newTextLength > oldTextLength && !isOldVersion)
          for (int i = minLength; i < newTextLength; i++)
            TextSpan(
                text: editedText[i],
                style: TextStyle(
                  backgroundColor: Colors.green,
                )),
      ],
    ),
  );
}

Future<void> showRatingsBottomSheet(context, {double bottomPadding = 0}) async {
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(13),
        topRight: Radius.circular(13),
      )),
      // backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300 + bottomPadding,
          child: RatingsPage(),
        );
      });
}

Widget settingTile(String label, {String? description, Function? onTap, IconData? trailingIcon}) {
  return ListTile(
    minVerticalPadding: 24.0,
    title: Text(
      '$label',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
    ),
    subtitle: description != null
        ? Text(
            '$description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )
        : SizedBox.shrink(),
    onTap: () {
      if (onTap != null) {
        onTap();
      }
    },
    trailing: trailingIcon != null ? Icon(trailingIcon) : null,
  );
}
