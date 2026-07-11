import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/contribution_stats.dart';

/// Domain contract for reading a user's profile and their contribution stats.
/// The implementation lives in the data layer (`ProfileRepositoryImpl`), over
/// Supabase via the shared `UserService` + `EditHistoryService` data sources.
abstract class ProfileRepository {
  /// Re-fetches the signed-in user's profile. Phone-only users have no Supabase
  /// row (no email), so they resolve to [session] unchanged.
  Future<UserModel> refreshCurrentUser(UserModel session);

  /// Fetches another user's profile by [email] (the read-only view).
  Future<UserModel> profileByEmail(String email);

  /// Aggregates the user's edit history into contribution tallies.
  Future<ContributionStats> contributionStats(UserModel user);
}
