// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme {
    return _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}