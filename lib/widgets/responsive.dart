import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vocabhub/utils/size_utils.dart';

class ResponsiveBuilder extends StatefulWidget {
  final WidgetBuilder desktopBuilder;
  final WidgetBuilder mobileBuilder;

  const ResponsiveBuilder({Key? key, required this.desktopBuilder, required this.mobileBuilder})
      : super(key: key);

  @override
  State<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends State<ResponsiveBuilder> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: LayoutBuilder(builder: (context, constraints) {
        SizeUtils.size = Size(constraints.maxWidth, constraints.maxHeight);
        if (!SizeUtils.isMobile) {
          return widget.desktopBuilder(context);
        }
        return Stack(
          children: [
            CustomPaint(
              painter: BackgroundPainter(
                primaryColor: colorScheme.primary,
                secondaryColor: colorScheme.onPrimaryContainer,
              ),
            ),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
            widget.mobileBuilder(context),
          ],
        );
      }),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  BackgroundPainter({this.primaryColor = Colors.green, this.secondaryColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = primaryColor;
    canvas.save();
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 200);
    // paint square
    canvas.drawRect(
        Rect.fromCenter(
          center: Offset(150, 200),
          width: 200,
          height: 200,
        ),
        paint);
    canvas.translate(-180, -500);
    // paint abstract shape
    paint.color = secondaryColor;
    canvas.drawPath(
        Path()
          ..moveTo(400, 500)
          ..quadraticBezierTo(500, 400, 600, 500)
          ..quadraticBezierTo(700, 600, 600, 700)
          ..quadraticBezierTo(500, 800, 400, 700)
          ..quadraticBezierTo(300, 600, 400, 500)
          ..close(),
        paint);
    canvas.restore();
    paint.blendMode = BlendMode.overlay;

    // paint triangle
    paint.color = Colors.blueAccent;
    canvas.drawPath(
        Path()
          ..moveTo(-150, 400)
          ..lineTo(200, 400)
          ..lineTo(200, 600)
          ..close(),
        paint);

    paint.color = Colors.orange.shade600;
    canvas.drawPath(
        Path()
          ..moveTo(300, 400)
          ..lineTo(600, 600)
          ..lineTo(100, 700)
          ..close(),
        paint);

    paint.color = Colors.redAccent;
    canvas.drawCircle(Offset(200, 300), 100, paint);
    paint.color = Colors.blue.shade600;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
