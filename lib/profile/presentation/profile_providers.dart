import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/profile/data/profile_repository_impl.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';
import 'package:vocabhub/profile/domain/usecases/check_username_availability.dart';
import 'package:vocabhub/profile/domain/usecases/delete_account.dart';
import 'package:vocabhub/profile/domain/usecases/load_contributions.dart';
import 'package:vocabhub/profile/domain/usecases/load_profile.dart';
import 'package:vocabhub/profile/domain/usecases/update_profile.dart';

/// Wiring for the profile feature. The repository sits over the shared
/// UserService / EditHistoryService data sources.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepositoryImpl());

final loadProfileProvider = Provider<LoadProfile>(
  (ref) => LoadProfile(ref.watch(profileRepositoryProvider)),
);

final loadContributionsProvider = Provider<LoadContributions>(
  (ref) => LoadContributions(ref.watch(profileRepositoryProvider)),
);

final checkUsernameProvider = Provider<CheckUsernameAvailability>(
  (ref) => CheckUsernameAvailability(ref.watch(profileRepositoryProvider)),
);

final updateProfileProvider = Provider<UpdateProfile>(
  (ref) => UpdateProfile(ref.watch(profileRepositoryProvider)),
);

final deleteAccountProvider = Provider<DeleteAccount>(
  (ref) => DeleteAccount(ref.watch(profileRepositoryProvider)),
);
