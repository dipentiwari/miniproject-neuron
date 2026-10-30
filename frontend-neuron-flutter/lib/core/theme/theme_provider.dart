import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

enum ThemePreference { dark, light, system }

class ThemeProvider extends ChangeNotifier {
  ThemePreference _preference = ThemePreference.dark;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  ThemePreference get preference => _preference;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(AppConstants.keyThemePref) ?? ThemePreference.dark.index;
    _preference = ThemePreference.values[index];
    _applyPreference();
    notifyListeners();
  }

  void _applyPreference() {
    switch (_preference) {
      case ThemePreference.light:
        _themeMode = ThemeMode.light;
      case ThemePreference.dark:
        _themeMode = ThemeMode.dark;
      case ThemePreference.system:
        _themeMode = ThemeMode.system;
    }
  }

  Future<void> setPreference(ThemePreference pref) async {
    _preference = pref;
    _applyPreference();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemePref, pref.index);
  }

  Future<void> toggleTheme() async {
    final next = isDarkMode ? ThemePreference.light : ThemePreference.dark;
    await setPreference(next);
  }
}
