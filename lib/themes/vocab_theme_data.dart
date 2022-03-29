import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/main.dart';

class VocabThemeData {
  static Color primaryGreen = Color(0xff4c9648);
  static Color primaryGrey = Colors.grey;
  static Color primaryBlue = Colors.blueAccent;
  static Color primaryColor = primaryGreen;
  static Color secondaryColor = primaryGreen.withOpacity(0.6);
  static Color primaryDark = Colors.black.withOpacity(0.6);
  static Color secondaryDark = Colors.black.withOpacity(0.7);
  static Color shrinePink = Color(0xffFEDBD0);
  static Color navbarSurfaceGrey = Color(0xffF2F4F7);
  static Color? surfaceGreen = Colors.green[50];
  static Color? surfaceGrey = Colors.grey[850];
  static Color? errorColor = Colors.red;

  static Color color1 = Color(0xff1D976C);
  static Color color2 = Color(0xff93F9B9);
 static LinearGradient primaryGradient = LinearGradient(
      colors: [color1.withOpacity(0.1), color2.withOpacity(0.2)]);
static  LinearGradient secondaryGradient = LinearGradient(
      colors: [primaryBlue.withOpacity(0.1), primaryGreen.withOpacity(0.2)]);
  static TextStyle listSubtitleStyle = TextStyle(fontSize: 12);

  static TextTheme googleFontsTextTheme(BuildContext context) {
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
}
