import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/main.dart';

import 'colors.dart';

/// mention style constants to be used across different pages in you app here
/// e.g borderRadius,textstyle,gradients etc
///

Color color1 = Color(0xff1D976C);
Color color2 = Color(0xff93F9B9);
LinearGradient primaryGradient =
    LinearGradient(colors: [color1.withOpacity(0.1), color2.withOpacity(0.2)]);
LinearGradient secondaryGradient = LinearGradient(
    colors: [primaryBlue.withOpacity(0.1), primaryGreen.withOpacity(0.2)]);
TextStyle listSubtitleStyle = TextStyle(fontSize: 12);

TextTheme googleFontsTextTheme(BuildContext context) {
  bool isDark = darkNotifier.value;
  return GoogleFonts.quicksandTextTheme(TextTheme(
    headline1: GoogleFonts.quicksand(
        fontSize: 72.0,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold),
    headline2: GoogleFonts.quicksand(
        fontSize: 48.0, color: Colors.white, fontWeight: FontWeight.w500),
    headline3: GoogleFonts.quicksand(
        fontSize: 36.0,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500),
    headline4: GoogleFonts.quicksand(
        fontSize: 22,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w300),
    headline5: GoogleFonts.quicksand(
        fontSize: 16.0, color: isDark ? Colors.white : Colors.black),
    headline6: GoogleFonts.quicksand(
        fontSize: 12.0,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w300),
    caption: Theme.of(context)
        .textTheme
        .caption!
        .copyWith(color: Colors.grey, fontSize: 12),
    subtitle1: GoogleFonts.quicksand(
        fontSize: 20,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w300),
  ));
}
