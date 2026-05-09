
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('EUR') {
    _loadCurrency();
  }

  static const _key = 'selected_currency';

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'EUR';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency);
    state = currency;
  }
}