import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final VoidCallback onRetry;
  final String errorMessage;
  const ErrorPage({Key? key, required this.onRetry, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Text(
            "Tap to retry",
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      )),
    );
  }
}
