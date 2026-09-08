import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadPreferences();
  }

  bool _darkMode = false;
  bool _notificationsEnabled = true;

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(darkModeKey, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(notificationsKey, value);
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    _darkMode = preferences.getBool(darkModeKey) ?? false;
    _notificationsEnabled = preferences.getBool(notificationsKey) ?? true;
    notifyListeners();
  }
}
