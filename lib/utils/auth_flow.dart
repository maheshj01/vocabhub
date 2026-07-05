import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
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

/// Gate for actions that write email-keyed data (adding words, bookmarks).
///
/// Returns true if the current user already has an email. Otherwise (a phone
/// user on a browse-only session) it prompts them to link a Google account for
/// a verified email, and returns whether that succeeded. Callers should only
/// proceed with the contribution when this returns true.
Future<bool> requireEmail(BuildContext context) async {
  if (authController.user.email.isNotEmpty) return true;

  final proceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add your email'),
      content: const Text(
        'To contribute and sync your bookmarks across devices, link an email '
        'to your account. We\'ll use your Google account to verify it.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Not now')),
        FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue with Google')),
      ],
    ),
  );
  if (proceed != true) return false;

  final result = await authController.linkEmailWithGoogle(
    fcmToken: pushNotificationService.fcmToken,
  );
  if (!context.mounted) return authController.user.email.isNotEmpty;
  if (result.outcome != AuthOutcome.success) {
    NavbarNotifier.showSnackBar(context, result.errorMessage ?? 'Could not link your email.');
    return false;
  }
  return true;
}
