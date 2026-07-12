import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/services/services/word_state_service.dart';
import 'package:vocabhub/utils/logger.dart';

/// Single source of truth for which words the user is tracking:
///   • bookmarked  = [WordState.unknown]  (saved to learn)
///   • mastered    = [WordState.known]    (already learned)
///
/// Local-first: a guest is tracked on-device (SharedPreferences) so the core
/// loop — and the dashboard's progress — works before any account exists.
/// A signed-in user is backed by Supabase. On sign-in, locally-tracked words
/// are merged into the account so nothing the guest saved is lost.
class WordTrackingController extends ChangeNotifier {
  static const String _prefsKey = 'guest_word_states_v1';
  final _logger = Logger('WordTrackingController');

  SharedPreferences? _prefs;
  Map<String, WordState> _states = <String, WordState>{};
  bool _isLoading = false;
  bool _isGuest = true;
  String _email = '';

  Map<String, WordState> get states => _states;
  bool get isLoading => _isLoading;
  int get bookmarkedCount => _states.values.where((s) => s == WordState.unknown).length;
  int get masteredCount => _states.values.where((s) => s == WordState.known).length;
  bool isBookmarked(String wordId) => _states[wordId] == WordState.unknown;
  bool isMastered(String wordId) => _states[wordId] == WordState.known;

  Future<void> initService() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Loads the tracking set for [user]. Call on app start and whenever the
  /// session changes. Guests read from the device; members read from Supabase.
  Future<void> load(UserModel user) async {
    _isGuest = !(user.isLoggedIn && user.email.isNotEmpty);
    _email = user.email;
    _isLoading = true;
    notifyListeners();
    try {
      _states = _isGuest ? _readLocal() : await _readRemote(_email);
    } catch (e) {
      _logger.e('Failed to load tracking: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets [word] to [state] (known/unknown/unanswered), optimistically updating
  /// local state then persisting to the active backend.
  Future<void> setWordState(Word word, WordState state) async {
    _states = {..._states, word.id: state};
    notifyListeners();
    try {
      if (_isGuest) {
        await _writeLocal();
      } else {
        await WordStateService.storeWordPreference(word.id, _email, state);
      }
    } catch (e) {
      _logger.e('Failed to persist word state: $e');
    }
  }

  Future<void> toggleBookmark(Word word) =>
      setWordState(word, isBookmarked(word.id) ? WordState.unanswered : WordState.unknown);

  Future<void> toggleMastered(Word word) =>
      setWordState(word, isMastered(word.id) ? WordState.unanswered : WordState.known);

  /// Pushes a guest's locally-tracked words into their account after sign-in,
  /// then re-loads from the remote backend. Safe to call for every sign-in
  /// (a no-op when there's nothing local).
  Future<void> mergeOnSignIn(UserModel user) async {
    if (user.email.isEmpty) return;
    final local = _readLocal();
    for (final entry in local.entries) {
      if (entry.value == WordState.unanswered) continue;
      try {
        await WordStateService.storeWordPreference(entry.key, user.email, entry.value);
      } catch (e) {
        _logger.d('merge skip ${entry.key}: $e');
      }
    }
    await _prefs?.remove(_prefsKey);
    await load(user);
  }

  // --- backends ------------------------------------------------------------

  Map<String, WordState> _readLocal() {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, WordState.values.byName(v as String)));
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeLocal() async {
    final encoded = json.encode(_states.map((k, v) => MapEntry(k, v.name)));
    await _prefs?.setString(_prefsKey, encoded);
  }

  Future<Map<String, WordState>> _readRemote(String email) async {
    final results = await Future.wait([
      VocabStoreService.getBookmarks(email, isBookmark: true), // unknown
      VocabStoreService.getBookmarks(email, isBookmark: false), // known
    ]);
    final map = <String, WordState>{};
    for (final w in results[1]) {
      map[w.id] = WordState.known;
    }
    for (final w in results[0]) {
      map[w.id] = WordState.unknown;
    }
    return map;
  }
}
