import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';

/// Loads the profile to display: the signed-in user (refreshed) or, in
/// read-only mode, another user's profile by email.
class LoadProfile {
  final ProfileRepository _repository;
  const LoadProfile(this._repository);

  Future<UserModel> call({
    required UserModel session,
    required bool readOnly,
    String email = '',
  }) {
    if (readOnly) return _repository.profileByEmail(email);
    return _repository.refreshCurrentUser(session);
  }
}
