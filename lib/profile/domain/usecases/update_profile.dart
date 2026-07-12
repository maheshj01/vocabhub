import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';

/// Persists profile edits. Returns true on success.
class UpdateProfile {
  final ProfileRepository _repository;
  const UpdateProfile(this._repository);

  Future<bool> call(UserModel user) => _repository.updateProfile(user);
}
