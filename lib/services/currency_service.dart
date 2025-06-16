import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class CurrencyService {
  static const String _favoritesKey = 'favorite_currencies';
  
  // Hardcoded currency data with exchange rates (base: USD)
  static final List<Currency> _allCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸', rate: 1.0),
    Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺', rate: 0.85),
    Currency(code: 'GBP', name: 'UK Pound Sterling', flag: '🇬🇧', rate: 0.73),
    Currency(code: 'JPY', name: 'Japan Yen', flag: '🇯🇵', rate: 110.0),
    Currency(code: 'KRW', name: 'Korea Won', flag: '🇰🇷', rate: 1200.0),
    Currency(code: 'CNY', name: 'China Yuan', flag: '🇨🇳', rate: 6.45),
    Currency(code: 'THB', name: 'Thai Baht', flag: '🇹🇭', rate: 33.0),
    Currency(code: 'SGD', name: 'Singapore Dollar', flag: '🇸🇬', rate: 1.35),
    Currency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺', rate: 1.35),
    Currency(code: 'CAD', name: 'Canadian Dollar', flag: '🇨🇦', rate: 1.25),
    Currency(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭', rate: 0.92),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', flag: '🇭🇰', rate: 7.8),
    Currency(code: 'SEK', name: 'Swedish Krona', flag: '🇸🇪', rate: 8.5),
    Currency(code: 'NOK', name: 'Norwegian Krone', flag: '🇳🇴', rate: 8.8),
    Currency(code: 'DKK', name: 'Danish Krone', flag: '🇩🇰', rate: 6.3),
    Currency(code: 'PLN', name: 'Polish Zloty', flag: '🇵🇱', rate: 3.9),
    Currency(code: 'CZK', name: 'Czech Koruna', flag: '🇨🇿', rate: 21.5),
    Currency(code: 'HUF', name: 'Hungarian Forint', flag: '🇭🇺', rate: 295.0),
    Currency(code: 'RUB', name: 'Russian Ruble', flag: '🇷🇺', rate: 75.0),
    Currency(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳', rate: 74.0),
  ];

  List<Currency> getAllCurrencies() {
    return List.from(_allCurrencies);
  }

  List<Currency> getFavoriteCurrencies() {
    return _allCurrencies.where((currency) => currency.isFavorite).toList();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    for (final currencyCode in favoritesJson) {
      final currency = _allCurrencies.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => _allCurrencies.first,
      );
      currency.isFavorite = true;
    }
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteCodes = _allCurrencies
        .where((currency) => currency.isFavorite)
        .map((currency) => currency.code)
        .toList();
    
    await prefs.setStringList(_favoritesKey, favoriteCodes);
  }

  Future<void> toggleFavorite(String currencyCode) async {
    final currency = _allCurrencies.firstWhere((c) => c.code == currencyCode);
    currency.isFavorite = !currency.isFavorite;
    await saveFavorites();
  }

  double convertCurrency(double amount, String fromCode, String toCode) {
    if (fromCode == toCode) return amount;
    
    final fromCurrency = _allCurrencies.firstWhere((c) => c.code == fromCode);
    final toCurrency = _allCurrencies.firstWhere((c) => c.code == toCode);
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromCurrency.rate;
    return usdAmount * toCurrency.rate;
  }

  List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return getAllCurrencies();
    
    return _allCurrencies.where((currency) {
      return currency.name.toLowerCase().contains(query.toLowerCase()) ||
             currency.code.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
} 