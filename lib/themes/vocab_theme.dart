import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/utils/settings.dart';

class VocabTheme {
  static final VocabTheme _singleton = VocabTheme._internal();
  VocabTheme._internal();

  static Color primaryGrey = Colors.grey;
  static Color primaryBlue = Colors.blueAccent;
  static Color primaryColor = Color(0xff4c9648);
  static Color secondaryColor = primaryColor.withOpacity(0.6);
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
  static LinearGradient primaryGradient =
      LinearGradient(colors: [color1.withOpacity(0.1), color2.withOpacity(0.2)]);
  static LinearGradient secondaryGradient =
      LinearGradient(colors: [primaryBlue.withOpacity(0.1), primaryColor.withOpacity(0.2)]);
  static TextStyle listSubtitleStyle = TextStyle(fontSize: 12);

  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;
  static const Color navigationBarColor = Color(0xffF2F4F7);
  bool _isDark = false;

  static bool get isDark => _singleton._isDark;

  static set isDark(bool value) {
    _singleton._isDark = value;
  }

  static ColorScheme get colorScheme =>
      Settings.getTheme == ThemeMode.light ? lightColorScheme : darkColorScheme;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  static ThemeData lightThemeData = _themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = _themeData(darkColorScheme, _darkFocusColor);

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

  static ThemeData _themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: colorScheme.brightness,
      ),
      textTheme: googleFontsTextTheme,
      // Matches manifest.json colors and background color.
      primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        titleTextStyle: googleFontsTextTheme.headlineMedium,
        elevation: 2.2,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      navigationRailTheme: NavigationRailThemeData(
          backgroundColor: colorScheme.surface,
          unselectedIconTheme: IconThemeData(
            color: Colors.black87,
          ),
          unselectedLabelTextStyle: googleFontsTextTheme.titleLarge,
          indicatorColor: colorScheme.primary),
      iconTheme: IconThemeData(color: colorScheme.primary),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: googleFontsTextTheme.titleMedium!.apply(color: _darkFillColor),
      ),
      bottomAppBarTheme: BottomAppBarTheme(color: colorScheme.primary),
    );
  }

  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color.fromRGBO(76, 150, 72, 1.0),
    primaryContainer: const Color(0xFF117378),
    secondary: const Color(0xFFEFF3F3),
    secondaryContainer: const Color(0xFFFAFBFB),
    background: background!,
    surface: const Color(0XFFFFFFFF),
    onBackground: Colors.black,
    error: Colors.red,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: const Color(0xFF322942),
    onSurface: Color.fromRGBO(76, 150, 72, 1.0),
  );

  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFF8383),
    primaryContainer: Color(0xFF1CDEC9),
    secondary: Color(0xFF4D1F7C),
    secondaryContainer: Color(0xFF451B6F),
    background: Color(0xFF241E30),
    surface: Color(0xFF1F1929),
    onBackground: Color(0x0DFFFFFF), // White with 0.05 opacity
    error: Colors.red,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
  );

  static TextTheme googleFontsTextTheme = GoogleFonts.quicksandTextTheme(TextTheme(
    displayLarge: GoogleFonts.quicksand(
        fontSize: 72.0, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
    displayMedium: GoogleFonts.quicksand(
        fontSize: 48.0, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
    displaySmall: GoogleFonts.quicksand(
        fontSize: 36.0, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
    headlineMedium: GoogleFonts.quicksand(
        fontSize: 22, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
    headlineSmall:
        GoogleFonts.quicksand(fontSize: 16.0, color: isDark ? Colors.white : Colors.black),
    titleLarge: GoogleFonts.quicksand(
        fontSize: 12.0, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w300),
    bodySmall: GoogleFonts.quicksand(color: Colors.grey, fontSize: 12),
    titleMedium: GoogleFonts.quicksand(
        fontSize: 20, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w300),
    titleSmall: GoogleFonts.quicksand(fontSize: 16, color: lightblue, fontWeight: FontWeight.w300),
  ));
}
