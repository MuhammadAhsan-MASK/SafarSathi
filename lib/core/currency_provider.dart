import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = 'PKR';
  
  final Map<String, double> _rates = {
    'PKR': 1.0,
    'USD': 280.0,
    'GBP': 350.0,
  };

  final Map<String, String> _symbols = {
    'PKR': 'Rs.',
    'USD': '\$',
    'GBP': '£',
  };

  String get selectedCurrency => _selectedCurrency;
  String get symbol => _symbols[_selectedCurrency]!;
  double get rate => _rates[_selectedCurrency]!;
  List<String> get currencies => _rates.keys.toList();

  void setCurrency(String currency) {
    if (_rates.containsKey(currency)) {
      _selectedCurrency = currency;
      notifyListeners();
    }
  }

  String formatPrice(double amount) {
    double converted = amount / rate;
    // For smaller values (like USD/GBP), show 2 decimal places. For PKR, show 0.
    return '$symbol ${converted.toStringAsFixed(converted < 100 ? 2 : 0)}';
  }
}
