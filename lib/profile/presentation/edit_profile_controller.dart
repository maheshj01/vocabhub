import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/usecases/check_username_availability.dart';
import 'package:vocabhub/profile/domain/usecases/delete_account.dart';
import 'package:vocabhub/profile/domain/usecases/update_profile.dart';
import 'package:vocabhub/profile/presentation/edit_profile_state.dart';

/// Per-view controller for the edit-profile form. Orchestrates username
/// validation (debounced), saving, and account deletion via use cases, exposing
/// immutable [EditProfileState]. Session caching + navigation stay with the
/// widget (they need the global session / BuildContext).
class EditProfileController extends ChangeNotifier {
  EditProfileController({
    required CheckUsernameAvailability checkUsername,
    required UpdateProfile updateProfile,
    required DeleteAccount deleteAccount,
    required String currentUsername,
  })  : _checkUsername = checkUsername,
        _updateProfile = updateProfile,
        _deleteAccount = deleteAccount,
        _currentUsername = currentUsername;

  final CheckUsernameAvailability _checkUsername;
  final UpdateProfile _updateProfile;
  final DeleteAccount _deleteAccount;
  final String _currentUsername;

  static const _debounceDelay = Duration(milliseconds: 350);
  Timer? _debounce;
  int _checkToken = 0;

  EditProfileState _state = const EditProfileState();
  EditProfileState get state => _state;

  void _emit(EditProfileState next) {
    _state = next;
    notifyListeners();
  }

  /// Debounced username validation as the user types.
  void onUsernameChanged(String value) {
    final username = value.trim();
    _debounce?.cancel();

    if (username.isEmpty) {
      _emit(_state.copyWith(usernameStatus: UsernameStatus.empty));
      return;
    }
    if (username == _currentUsername) {
      _emit(_state.copyWith(usernameStatus: UsernameStatus.idle));
      return;
    }

    _emit(_state.copyWith(usernameStatus: UsernameStatus.checking));
    final token = ++_checkToken;
    _debounce = Timer(_debounceDelay, () async {
      final result = await _checkUsername(username);
      if (token != _checkToken) return; // superseded by a newer keystroke
      _emit(_state.copyWith(
          usernameStatus: switch (result) {
        UsernameAvailability.available => UsernameStatus.available,
        UsernameAvailability.taken => UsernameStatus.taken,
        UsernameAvailability.invalidFormat => UsernameStatus.invalid,
      }));
    });
  }

  /// Saves [username] onto [user]. Returns the updated user on success (for the
  /// caller to cache + navigate), or null on failure.
  Future<UserModel?> save(UserModel user, String username) async {
    _emit(_state.copyWith(isSaving: true));
    final edited = user.copyWith(username: username.trim());
    final ok = await _updateProfile(edited);
    _emit(_state.copyWith(isSaving: false));
    return ok ? edited : null;
  }

  /// Deletes [user]'s account. Returns true on success.
  Future<bool> deleteAccount(UserModel user) async {
    _emit(_state.copyWith(isDeleting: true));
    final ok = await _deleteAccount(user);
    _emit(_state.copyWith(isDeleting: false));
    return ok;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
