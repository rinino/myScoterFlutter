import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode != null && langCode.isNotEmpty) {
      state = Locale(langCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode.isEmpty) {
      await prefs.remove('language_code');
      state = null; // Ritorna alla lingua di sistema
    } else {
      await prefs.setString('language_code', languageCode);
      state = Locale(languageCode);
    }
  }
}