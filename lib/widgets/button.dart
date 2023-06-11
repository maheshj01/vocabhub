import 'package:flutter/material.dart';
import 'package:vocabhub/utils/extensions.dart';

class VHButton extends StatefulWidget {
  VHButton(
      {Key? key,
      this.backgroundColor = Colors.white,
      this.foregroundColor = Colors.black,
      required this.onTap,
      required this.label,
      this.height = 55.0,
      this.width,
      this.fontSize = 18,
      this.isLoading = false,
      this.leading})
      : super(key: key);

  final void Function()? onTap;

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
  _VHButtonState createState() => _VHButtonState();
}

class _VHButtonState extends State<VHButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: (widget.onTap == null)
          ? null
          : ButtonStyle(
              minimumSize: MaterialStateProperty.resolveWith(
                  (states) => Size(widget.width ?? 120, widget.height)),
              maximumSize: MaterialStateProperty.resolveWith(
                  (states) => Size(widget.width ?? 120, widget.height)),
              foregroundColor: MaterialStateColor.resolveWith((states) => widget.foregroundColor),
              backgroundColor: MaterialStateColor.resolveWith((states) => widget.backgroundColor)),
      onPressed: widget.isLoading || (widget.onTap == null) ? null : widget.onTap,
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.fontSize,
                      color: widget.foregroundColor),
                ),
              ],
            ),
    );
  }
}
