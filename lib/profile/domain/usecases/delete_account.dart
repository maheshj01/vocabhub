import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/profile_repository.dart';

/// Soft-deletes the account. Returns true on success.
class DeleteAccount {
  final ProfileRepository _repository;
  const DeleteAccount(this._repository);

  Future<bool> call(UserModel user) => _repository.deleteAccount(user);
}
