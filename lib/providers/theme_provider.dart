import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main and override this provider');
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'user_theme_mode';

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = _prefs.getInt(_themeKey);
    if (savedMode != null) {
      state = ThemeMode.values[savedMode];
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeNotifier(prefs);
});
