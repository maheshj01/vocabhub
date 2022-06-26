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

  static bool isDesktop() {
    return _size.width > kDesktopBreakPoint;
  }

  static bool isTablet() {
    return _size.width > kTabletBreakPoint && _size.width < kDesktopBreakPoint;
  }

  static bool isMobile() {
    return _size.width < kTabletBreakPoint;
  }
}
