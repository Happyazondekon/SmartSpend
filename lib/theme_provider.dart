import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static ThemeProvider? _instance;

  // Singleton pattern pour garantir une seule instance
  ThemeProvider._internal();

  factory ThemeProvider() {
    _instance ??= ThemeProvider._internal();
    return _instance!;
  }

  bool get isDarkMode => _isDarkMode;

  // Initialiser le thème depuis SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Changer le thème et sauvegarder
  Future<void> toggleTheme(bool newValue) async {
    if (_isDarkMode != newValue) {
      _isDarkMode = newValue;
      notifyListeners();

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', newValue);
    }
  }
}