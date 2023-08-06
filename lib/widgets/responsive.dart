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
    return Material(
      child: LayoutBuilder(builder: (context, constraints) {
        SizeUtils.size = Size(constraints.maxWidth, constraints.maxHeight);
        if (!SizeUtils.isMobile) {
          return widget.desktopBuilder(context);
        }
        return widget.mobileBuilder(context);
      }),
    );
  }
}
