import 'package:flutter/material.dart';
import 'package:vocabhub/utils/extensions.dart';

class VocabButton extends StatefulWidget {
  VocabButton(
      {Key? key,
      this.backgroundColor = Colors.white,
      this.foregroundColor = Colors.black,
      required this.onTap,
      required this.label,
      this.height = 55.0,
      this.width,
      this.fontSize,
      this.isLoading = false,
      this.leading})
      : super(key: key);

  final Function() onTap;

  /// label on the button
  final String label;

  final Widget? leading;

  final Color backgroundColor;

  final Color foregroundColor;

  final double height;

  final double? fontSize;

  final double? width;
  final bool isLoading;

  @override
  _VocabButtonState createState() => _VocabButtonState();
}

class _VocabButtonState extends State<VocabButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.resolveWith(
              (states) => Size(widget.width ?? 120, widget.height)),
          maximumSize: MaterialStateProperty.resolveWith(
              (states) => Size(widget.width ?? 120, widget.height)),
          foregroundColor: MaterialStateColor.resolveWith(
              (states) => widget.foregroundColor),
          backgroundColor: MaterialStateColor.resolveWith(
              (states) => widget.backgroundColor)),
      onPressed: widget.isLoading ? null : widget.onTap,
      child: widget.isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.foregroundColor),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.leading ?? SizedBox.shrink(),
                (widget.leading == null ? 0.0 : 20.0).hSpacer(),
                Text(
                  '${widget.label}',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.fontSize,
                      color: widget.foregroundColor),
                ),
              ],
            ),
    );
  }
}
