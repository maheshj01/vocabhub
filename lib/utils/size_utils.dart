import 'package:flutter/material.dart';

class SizeUtils {
  // Specifies the width above kTabletBreakpoint is a tablet
  static const kTabletBreakPoint = 600;

  // Specifies the width above kDesktopBreakPoint is a Desktop
  static const kDesktopBreakPoint = 1024;

  /// screen size
  static Size _size = Size.zero;

  static Size get size => _size;

  static set size(Size value) {
    _size = value;
  }

  static bool get isDesktop=>
    _size.width > kDesktopBreakPoint;

  static bool get isTablet=> _size.width > kTabletBreakPoint && _size.width < kDesktopBreakPoint;


  static bool get isMobile =>_size.width < kTabletBreakPoint;
}
