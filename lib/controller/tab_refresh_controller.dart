import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navbar tab indices, shared so the navbar and individual tab views agree on
/// positions without importing each other.
class AppTabs {
  const AppTabs._();

  static const int dashboard = 0;
  static const int search = 1;
  static const int explore = 2;
  static const int profile = 3;
}

/// A general per-tab "please refresh" signal.
///
/// [requestRefresh] bumps a tab's counter; a tab view watches only *its own*
/// counter (via `tabRefreshProvider.select`) and silently re-fetches when it
/// changes. Extensible to any tab — today only the profile tab reacts.
class TabRefreshNotifier extends Notifier<Map<int, int>> {
  @override
  Map<int, int> build() => const <int, int>{};

  void requestRefresh(int tabIndex) {
    state = {...state, tabIndex: (state[tabIndex] ?? 0) + 1};
  }
}

final tabRefreshProvider =
    NotifierProvider<TabRefreshNotifier, Map<int, int>>(TabRefreshNotifier.new);
