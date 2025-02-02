import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabTheme {
  VocabTheme._internal();

  static Color primaryDark = Colors.black.withOpacity(0.6);
  static Color secondaryDark = Colors.black.withOpacity(0.7);
  static Color shrinePink = Color(0xffFEDBD0);
  static Color navbarSurfaceGrey = Color(0xffF2F4F7);
  static Color? surfaceGreen = Color.fromARGB(255, 182, 216, 182);
  static Color? surfaceGrey = Colors.grey[850];
  static Color? background = Color(0XFFF8F8F8);
  static Color errorColor = Colors.red;
  static Color lightblue = Color(0XFF142D94);

  /// notification states color
  static Color approvedColor = Color(0xffD6F1E4);
  static Color rejectedColor = Color(0xffFFD2C8);
  static Color pendingColor = Color(0xffE2EBF9);
  static Color cancelColor = Color(0xffF2F2F2);

  static Color color1 = Color(0xff1D976C);
  static Color color2 = Color(0xff93F9B9);
  static TextStyle listSubtitleStyle = TextStyle(fontSize: 12);

  static List<Color> colorSeeds = [
    Colors.pink,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple
  ];

  static BoxShadow primaryShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: Offset(0, 5),
  );

  static BoxShadow secondaryShadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 10,
    offset: Offset(0, 5),
  );
  static BoxShadow notificationCardShadow = BoxShadow(
      color: Colors.black.withOpacity(0.1), blurRadius: 4.0, spreadRadius: 0, offset: Offset(0, 4));

  static TextTheme googleFontsTextTheme = GoogleFonts.quicksandTextTheme(TextTheme(
    displayLarge: GoogleFonts.quicksand(fontSize: 72.0, fontWeight: FontWeight.w500),
    displayMedium: GoogleFonts.quicksand(fontSize: 48.0, fontWeight: FontWeight.w500),
    displaySmall: GoogleFonts.quicksand(fontSize: 36.0, fontWeight: FontWeight.w500),
    headlineMedium: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w400),
    headlineSmall: GoogleFonts.quicksand(fontSize: 16.0),
    titleLarge: GoogleFonts.quicksand(fontSize: 12.0, fontWeight: FontWeight.w300),
    bodySmall: GoogleFonts.quicksand(color: Colors.grey, fontSize: 12),
    titleMedium: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w300),
    titleSmall: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w300),
  ));

  static ThemeData getThemeFromSeed(Color seed) {
    return ThemeData.dark(
      useMaterial3: true,
    ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: seed));
  }
}
