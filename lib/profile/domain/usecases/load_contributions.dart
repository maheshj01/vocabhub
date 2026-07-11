import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/contribution_stats.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';

/// Loads a user's contribution tallies (words added / edited / under review).
class LoadContributions {
  final ProfileRepository _repository;
  const LoadContributions(this._repository);

  Future<ContributionStats> call(UserModel user) => _repository.contributionStats(user);
}
