import 'package:flutter/material.dart';

/**
 * 
 * A utility class containing all the helper functions
 * to keep your code clean and readable and helping to maintain
 * the Single responsibility princple
 */

int squareOfNumber(int x) => x * x;

void showMessage(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2),
    void Function()? onPressed}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('$message'),
    duration: duration,
    action: onPressed == null
        ? null
        : SnackBarAction(label: 'ACTION', onPressed: onPressed),
  ));
}
