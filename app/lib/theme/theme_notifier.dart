import 'package:flutter/material.dart';

/// Holds theme mode state and notifies listeners on change.
/// Registered in service locator for DI-based theme toggling.
class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggle() {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
