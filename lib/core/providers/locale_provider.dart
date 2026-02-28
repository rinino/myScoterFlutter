import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Notifier per gestire il cambio lingua e la persistenza
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  static const _key = 'selected_language';

  // Carica la lingua all'avvio
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      state = Locale(code);
    } else {
      state = null; // null significa "Lingua di Sistema"
    }
  }

  // Cambia la lingua e salva
  Future<void> setLocale(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      state = null;
      await prefs.remove(_key);
    } else {
      state = Locale(languageCode);
      await prefs.setString(_key, languageCode);
    }
  }
}

// Il provider globale da usare nel main e nei widget
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});