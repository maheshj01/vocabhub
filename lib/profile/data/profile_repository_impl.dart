import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/profile/domain/contribution_stats.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/services/services/user_service.dart';

/// Supabase-backed implementation. Delegates to the app's shared data sources
/// (`UserService`, `EditHistoryService`) and maps their results into domain
/// types — the contribution-counting logic that used to live in the profile
/// widget now lives here.
class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<UserModel> refreshCurrentUser(UserModel session) {
    // Phone-only users have no Supabase row; refreshing by email would return an
    // empty user and sign them out, so keep the session as-is.
    if (session.email.isEmpty) return Future.value(session);
    return UserService.findByEmail(email: session.email, cache: true);
  }

  @override
  Future<UserModel> profileByEmail(String email) =>
      UserService.findByEmail(email: email, cache: false);

  @override
  Future<ContributionStats> contributionStats(UserModel user) async {
    final response = await EditHistoryService.getUserContributions(user);
    if (!response.didSucced || response.data == null) return ContributionStats.empty;

    final edits = response.data as List<NotificationModel>;
    int added = 0, edited = 0, review = 0;
    for (final history in edits) {
      final edit = history.edit;
      if (edit.state == EditState.approved) {
        if (edit.edit_type == EditType.add) {
          added++;
        } else if (edit.edit_type == EditType.edit) {
          edited++;
        }
      } else if (edit.state == EditState.pending) {
        review++;
      }
    }
    return ContributionStats(wordsAdded: added, wordsEdited: edited, underReview: review);
  }
}
