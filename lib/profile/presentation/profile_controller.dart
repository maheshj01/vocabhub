import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/profile/domain/usecases/load_contributions.dart';
import 'package:vocabhub/profile/domain/usecases/load_profile.dart';
import 'package:vocabhub/profile/presentation/profile_state.dart';

/// Per-view controller for a profile screen. Orchestrates the load/refresh use
/// cases and exposes immutable [ProfileState].
///
/// One instance per profile widget, so a read-only "other user" view
/// never clobbers the signed-in user's profile. (Chosen over a Riverpod family:
/// the app's idiom is per-instance ChangeNotifier controllers, and manual family
/// notifiers in Riverpod 3.x can't cleanly receive their argument.)
class ProfileController extends ChangeNotifier {
  ProfileController({
    required LoadProfile loadProfile,
    required LoadContributions loadContributions,
    required UserModel session,
    required bool isReadOnly,
    required String email,
  })  : _loadProfile = loadProfile,
        _loadContributions = loadContributions,
        _session = session,
        _isReadOnly = isReadOnly,
        _email = email;

  final LoadProfile _loadProfile;
  final LoadContributions _loadContributions;
  final UserModel _session;
  final bool _isReadOnly;
  final String _email;

  ProfileState _state = ProfileState.loading();
  ProfileState get state => _state;

  void _emit(ProfileState next) {
    _state = next;
    notifyListeners();
  }

  /// Initial load: the profile, then its contribution stats.
  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, error: null));
    try {
      final user = await _loadProfile(session: _session, readOnly: _isReadOnly, email: _email);
      _emit(_state.copyWith(user: user, isLoading: false));
      await _loadStats(user);
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        error: e is TimeoutException ? NETWORK_ERROR : SOMETHING_WENT_WRONG,
      ));
    }
  }

  /// Pull-to-refresh: re-fetch profile + stats, keeping current content on
  /// failure (so a transient network blip doesn't blank the screen).
  Future<void> refresh() async {
    try {
      final user = await _loadProfile(session: _session, readOnly: _isReadOnly, email: _email);
      _emit(_state.copyWith(user: user, error: null));
      await _loadStats(user);
    } catch (_) {
      // Keep showing the last good content.
    }
  }

  Future<void> _loadStats(UserModel user) async {
    final stats = await _loadContributions(user);
    _emit(_state.copyWith(stats: stats));
  }
}
