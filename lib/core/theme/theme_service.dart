import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadThemeFromPrefs();
  }

  // Metodo per cambiare il tema e notificare la UI
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Salva la scelta nella memoria locale
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  // Metodo interno per caricare il tema salvato all'avvio dell'app
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt('theme_mode');

    if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[savedThemeIndex];
      notifyListeners();
    }
  }
}