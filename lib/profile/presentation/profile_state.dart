import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/contribution_stats.dart';

const Object _unset = Object();

/// Immutable UI state for a profile screen. The controller rewrites it; widgets
/// only read it.
class ProfileState {
  final UserModel? user;
  final ContributionStats stats;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.user,
    this.stats = ContributionStats.empty,
    this.isLoading = false,
    this.error,
  });

  factory ProfileState.loading() => const ProfileState(isLoading: true);

  bool get hasUser => user != null;

  ProfileState copyWith({
    UserModel? user,
    ContributionStats? stats,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return ProfileState(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
