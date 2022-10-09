import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
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
    return Center(
        child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
      color ?? VocabTheme.primaryColor,
    )));
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
          text: e + ' ',
          style: style ??
              TextStyle(
                  fontWeight: (e.toLowerCase().contains(word.toLowerCase()))
                      ? FontWeight.bold
                      : FontWeight.normal)))
      .toList();
  textSpans.addAll(iterable);
  textSpans.add(TextSpan(text: '\n'));
  return SelectableText.rich(TextSpan(
      style: TextStyle(color: darkNotifier.value ? Colors.white : Colors.black),
      children: textSpans));
}

Widget storeRedirect(BuildContext context,
    {String redirectUrl = PLAY_STORE_URL,
    String assetUrl = 'assets/googleplay.png'}) {
  return GestureDetector(
    onTap: () {
      final firebaseAnalytics = Analytics();
      final width = MediaQuery.of(context).size.width;
      firebaseAnalytics.logRedirectToStore(
          width > SizeUtils.kTabletBreakPoint ? 'desktop' : 'mobile');
      launchUrl(redirectUrl);
    },
    child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset('$assetUrl', height: 50)),
  );
}

RichText buildNotification(String notification, String word,
    {TextStyle? style}) {
  final List<InlineSpan>? textSpans = [];
  final iterable = notification.split(' ').toList().map((e) {
    final isMatched = e.toLowerCase().contains(word.toLowerCase());
    return TextSpan(
        text: e + ' ',
        style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: isMatched ? FontWeight.bold : FontWeight.w400));
  }).toList();
  textSpans!.addAll(iterable);
  return RichText(text: TextSpan(text: '', children: textSpans));
}

Widget heading(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 20,
      color: VocabTheme.lightblue,
      fontWeight: FontWeight.w600,
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
        color: Colors.black,
      ),
      children: <TextSpan>[
        for (int i = 0; i < minLengthList; i++)
          if (oldTextList[i] == newTextList[i])
            TextSpan(text: newTextList[i] + ' ')
          else
            TextSpan(
                text:
                    isOldVersion ? oldTextList[i] + ' ' : newTextList[i] + ' ',
                style: TextStyle(
                  color: isOldVersion ? Colors.red : Colors.green,
                  decoration: isOldVersion ? TextDecoration.lineThrough : null,
                )),
        if (oldTextLength > newTextLength && isOldVersion)
          for (int i = minLengthList; i < oldTextLength; i++)
            TextSpan(
                text: oldTextList[i] + ' ',
                style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                )),
        if (newTextLength > oldTextLength && !isOldVersion)
          for (int i = minLengthList; i < newTextLength; i++)
            TextSpan(
                text: newTextList[i] + ' ',
                style: TextStyle(color: Colors.green)),
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
        fontSize: 16.0,
        color: Colors.black,
      ),
      children: <TextSpan>[
        for (int i = 0; i < minLength; i++)
          if (oldText[i] == editedText[i])
            TextSpan(text: editedText[i])
          else
            TextSpan(
                text: isOldVersion ? oldText[i] : editedText[i],
                style: TextStyle(
                  color: isOldVersion ? Colors.red : Colors.white,
                  decoration: isOldVersion ? TextDecoration.lineThrough : null,
                  backgroundColor: isOldVersion ? Colors.red : Colors.green,
                )),
        if (oldTextLength > newTextLength && isOldVersion)
          for (int i = minLength; i < oldTextLength; i++)
            TextSpan(
                text: oldText[i],
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.lineThrough,
                  backgroundColor: Colors.red,
                )),
        if (newTextLength > oldTextLength && !isOldVersion)
          for (int i = minLength; i < newTextLength; i++)
            TextSpan(
                text: editedText[i],
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.green,
                )),
      ],
    ),
  );
}
