import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  // Chiave per salvare la preferenza nel database locale
  static const String _themeKey = "selected_theme_mode";

  // Stato interno: di default impostiamo su sistema
  ThemeMode _themeMode = ThemeMode.system;

  // Getter per leggere il tema attuale dalle altre classi
  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadThemeFromPrefs();
  }

  /// Carica il tema salvato all'avvio dell'app
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      // Converte l'indice salvato nell'enum ThemeMode
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners(); // Notifica l'app di aggiornarsi
    }
  }

  /// Cambia il tema e lo salva permanentemente
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners(); // Cambia il tema istantaneamente nell'UI

    // Salva la scelta nelle SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Helper per sapere se siamo in Dark Mode (utile per logiche condizionali)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}