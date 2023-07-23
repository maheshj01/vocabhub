import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:vocabhub/utils/utils.dart';

class ErrorPage extends StatefulWidget {
  final VoidCallback onRetry;
  final String errorMessage;
  const ErrorPage({Key? key, required this.onRetry, required this.errorMessage}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RiveAnimationController _controller = OneShotAnimation('Animation 1');
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onRetry,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: SizeUtils.size.width * 0.8,
            child: RiveAnimation.asset(
              'assets/rive/error.riv',
              fit: BoxFit.cover,
              controllers: [_controller],
            ),
          ),
          16.0.vSpacer(),
          Text(
            widget.errorMessage,
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
