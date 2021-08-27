import 'package:flutter/material.dart';

class CircularClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  CircularClipper(this.radius, this.center);

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(radius: radius, center: center));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
