import 'package:flutter/material.dart';

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
TextStyle listTitleStyle = TextStyle(fontSize: 16);
TextStyle listSubtitleStyle = TextStyle(fontSize: 12);
