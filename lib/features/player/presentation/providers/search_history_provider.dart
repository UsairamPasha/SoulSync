import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const _key = 'soulsync_recent_searches';

  SearchHistoryNotifier() : super([]) {
    load();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getStringList(_key) ?? [];
    } catch (_) {}
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final clean = query.trim();
    final updated = [
      clean,
      ...state.where((s) => s.toLowerCase() != clean.toLowerCase())
    ];
    if (updated.length > 10) updated.removeLast();
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state);
    } catch (_) {}
  }

  Future<void> removeSearch(String query) async {
    final updated = state.where((s) => s != query).toList();
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state);
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}

final searchHistoryNotifierProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});
