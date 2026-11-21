class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final double rateToUsd; // 1 USD = X Currency

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rateToUsd,
  });
}

class CurrencyRegistry {
  static const List<Currency> currencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸', rateToUsd: 1.0),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺', rateToUsd: 0.95),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧', rateToUsd: 0.79),
    Currency(code: 'TRY', name: 'Türk Lirası', symbol: '₺', flag: '🇹🇷', rateToUsd: 34.50),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬', rateToUsd: 1.34),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵', rateToUsd: 154.20),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '🇨🇭', rateToUsd: 0.88),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦', rateToUsd: 1.40),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺', rateToUsd: 1.53),
  ];

  static Currency find(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }

  static double convert({required double amount, required String from, required String to}) {
    final fromCurrency = find(from);
    final toCurrency = find(to);
    final amountInUsd = amount / fromCurrency.rateToUsd;
    return amountInUsd * toCurrency.rateToUsd;
  }
}
