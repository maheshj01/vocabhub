import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    var titleCase = RegExp(r'\b\w');
    return (this
        .replaceAllMapped(titleCase, (match) => match.group(0)!.toUpperCase()));
  }

  String initals() {
    /// Returns the first letter of each word in the string.
    return this.split(' ').map((e) => e.capitalize().substring(0, 1)).join();
  }
}

extension ContainerBorderRadius on double {
  BorderRadiusGeometry get allRadius => BorderRadius.circular(this);

  BorderRadiusGeometry get topLeftRadius =>
      BorderRadius.only(topLeft: Radius.circular(this));

  BorderRadiusGeometry get topRightRadius =>
      BorderRadius.only(topRight: Radius.circular(this));

  BorderRadiusGeometry get bottomLeftRadius =>
      BorderRadius.only(bottomLeft: Radius.circular(this));

  BorderRadiusGeometry get bottomRightRadius =>
      BorderRadius.only(bottomRight: Radius.circular(this));

  BorderRadiusGeometry get verticalRadius => BorderRadius.vertical(
      top: Radius.circular(this), bottom: Radius.circular(this));

  BorderRadiusGeometry get horizontalRadius => BorderRadius.horizontal(
      left: Radius.circular(this), right: Radius.circular(this));

  BorderRadiusGeometry get topRadius =>
      BorderRadius.vertical(top: Radius.circular(this));

  BorderRadiusGeometry get bottomRadius =>
      BorderRadius.vertical(bottom: Radius.circular(this));

  BorderRadiusGeometry get leftRadius =>
      BorderRadius.horizontal(left: Radius.circular(this));

  BorderRadiusGeometry get rightRadius =>
      BorderRadius.horizontal(right: Radius.circular(this));

  BorderRadiusGeometry get topLeftBottomRightRadius => BorderRadius.only(
      topLeft: Radius.circular(this), bottomRight: Radius.circular(this));

  BorderRadiusGeometry get topRightBottomLeftRadius => BorderRadius.only(
      topRight: Radius.circular(this), bottomLeft: Radius.circular(this));
}
