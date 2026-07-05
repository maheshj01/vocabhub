import 'package:flutter/material.dart';

/// The three layout tiers the app adapts to. Chosen from *available width*
/// (window or parent constraints), never from hardware type — a phone in
/// free-form multi-window can be tablet-wide, and a desktop window can be
/// dragged phone-narrow.
enum ScreenType { mobile, tablet, desktop }

class SizeUtils {
  // Width at/above which we treat the layout as a tablet.
  static const kTabletBreakPoint = 600;

  // Width at/above which we treat the layout as a desktop.
  static const kDesktopBreakPoint = 1024;

  static const kExtendedDesktopBreakPoint = 1200;

  /// Comfortable reading width for forms/text/lists on large screens.
  /// Wrap such content in `ConstrainedBox(maxWidth: contentMaxWidth)` + `Center`
  /// so it doesn't stretch to unreadable line lengths.
  static const double contentMaxWidth = 720;

  /// Last known screen size. Kept in sync with the real app window by
  /// [ResponsiveBuilder] (via `MediaQuery.sizeOf`), so global reads of
  /// [isMobile] & friends reflect the window — not whatever sub-region
  /// happened to build last.
  static Size _size = Size.zero;

  static Size get size => _size;

  static set size(Size value) {
    _size = value;
  }

  /// Pure tier decision from an explicit width — prefer this inside a
  /// `LayoutBuilder` (`screenTypeOf(constraints.maxWidth)`) so local layout
  /// decisions follow the space actually allocated to the widget.
  static ScreenType screenTypeOf(double width) {
    if (width >= kDesktopBreakPoint) return ScreenType.desktop;
    if (width >= kTabletBreakPoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool get isDesktop => _size.width >= kDesktopBreakPoint;

  static bool get isExtendedDesktop => _size.width >= kExtendedDesktopBreakPoint;

  static bool get isTablet =>
      _size.width >= kTabletBreakPoint && _size.width < kDesktopBreakPoint;

  static bool get isMobile => _size.width < kTabletBreakPoint;
}
