import 'package:vocabhub/profile/domain/profile_repository.dart';

/// Result of validating a desired username.
enum UsernameAvailability { available, taken, invalidFormat }

/// Validates a username's format, then checks server-side availability.
class CheckUsernameAvailability {
  final ProfileRepository _repository;
  const CheckUsernameAvailability(this._repository);

  /// At least 3 chars, letters/digits/underscore only.
  static final RegExp _pattern = RegExp(r'^[a-zA-Z0-9_]{3,}$');

  Future<UsernameAvailability> call(String username) async {
    if (!_pattern.hasMatch(username)) return UsernameAvailability.invalidFormat;
    final available = await _repository.isUsernameAvailable(username);
    return available ? UsernameAvailability.available : UsernameAvailability.taken;
  }
}
