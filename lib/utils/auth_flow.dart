import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/utils/utility.dart';

/// Single place that turns an [AuthResult] into UI: navigation, analytics and
/// error messaging. Shared by every sign-in entry point (Google, phone, …) so
/// the outcome handling never drifts between them.
Future<void> handleAuthResult(
  BuildContext context,
  AuthResult result,
  Analytics analytics,
) async {
  switch (result.outcome) {
    case AuthOutcome.success:
      if (result.isNewUser) {
        analytics.logNewUser(result.user);
      } else {
        analytics.logSignIn(result.user);
      }
      if (!context.mounted) return;
      Navigate.pushAndPopAll(context, AdaptiveLayout(), transitionType: TransitionType.ttb);
      break;
    case AuthOutcome.accountDeleted:
      NavbarNotifier.showSnackBar(
        context,
        '$accountDeleted ${Constants.FEEDBACK_EMAIL_TO}',
        actionLabel: 'Contact Support',
        showCloseIcon: false,
        duration: const Duration(seconds: 10),
        onActionPressed: () => launchURL(accountActivationEmail),
      );
      break;
    case AuthOutcome.failed:
      NavbarNotifier.showSnackBar(context, bottom: 0, result.errorMessage ?? signInFailure);
      break;
  }
}
