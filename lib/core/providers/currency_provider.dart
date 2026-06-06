import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FIX: Sintassi moderna con NotifierProvider invece del vecchio StateNotifierProvider
final currencyProvider = NotifierProvider<CurrencyNotifier, String>(() {
  return CurrencyNotifier();
});

class CurrencyNotifier extends Notifier<String> {
  static const _key = 'selected_currency';

  @override
  String build() {
    // Stato iniziale di default (Euro)
    _loadCurrency();
    return '€';
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_key);
    if (savedCurrency != null) {
      state = savedCurrency;
    }
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency);
    state = currency;
  }
}