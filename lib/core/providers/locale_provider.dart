import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart'; // Nota: se passi a Riverpod più recente, questo diventerà 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:shared_preferences/shared_preferences.dart';

// Notifier per gestire il cambio lingua e la persistenza
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  static const _key = 'selected_language';

  // Lista di sicurezza delle lingue supportate dalla nostra app
  static const supportedLocales = ['it', 'en', 'es', 'fr', 'de', 'pt'];

  // Carica la lingua all'avvio
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);

    // FIX: Evita crash controllando che non sia vuoto e che sia supportato
    if (code != null && code.trim().isNotEmpty && supportedLocales.contains(code.trim())) {
      state = Locale(code.trim());
    } else {
      state = null; // null significa "Lingua di Sistema"
    }
  }

  // Cambia la lingua e salva
  Future<void> setLocale(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    // FIX: Se passiamo null o una stringa vuota, resettiamo alla lingua di sistema
    if (languageCode == null || languageCode.trim().isEmpty) {
      state = null;
      await prefs.remove(_key);
    } else {
      final cleanCode = languageCode.trim();

      // Controllo di sicurezza aggiuntivo
      if (supportedLocales.contains(cleanCode)) {
        state = Locale(cleanCode);
        await prefs.setString(_key, cleanCode);
      } else {
        // Fallback se arriva un codice strano
        state = null;
        await prefs.remove(_key);
      }
    }
  }
}

// Il provider globale da usare nel main e nei widget
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});