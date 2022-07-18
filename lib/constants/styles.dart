import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

Color stateToNotificationCardColor(EditState state) {
  switch (state) {
    case EditState.pending:
      return VocabTheme.pendingColor;
    case EditState.approved:
      return VocabTheme.approvedColor;
    case EditState.rejected:
      return VocabTheme.rejectedColor;
    case EditState.cancelled:
      return VocabTheme.cancelColor;
    default:
      return VocabTheme.pendingColor;
  }
}

IconData stateToNotificationIconData(EditState state) {
  switch (state) {
    case EditState.pending:
      return Icons.sync;
    case EditState.approved:
      return Icons.check;
    case EditState.rejected:
      return Icons.close;
    case EditState.cancelled:
      return Icons.cancel;
    default:
      return Icons.hourglass_empty;
  }
}

Color stateToIconColor(EditState state) {
  switch (state) {
    case EditState.pending:
      return Color(0XFF619AF1);
    case EditState.approved:
      return Color(0XFF4C9648);
    case EditState.rejected:
      return Color(0XFFFF8E8E);
    case EditState.cancelled:
      return Color(0xffAEAEAE);
    default:
      return Colors.grey;
  }
}
