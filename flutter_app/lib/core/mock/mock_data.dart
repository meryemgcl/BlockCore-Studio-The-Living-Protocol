class TransactionItem {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final String fromFlag;
  final String toFlag;
  final String title;
  final String subtitle;
  final String amount;
  final String secondaryAmount;
  final bool isPositive;

  const TransactionItem({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromFlag,
    required this.toFlag,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.secondaryAmount,
    this.isPositive = false,
  });
}

class CryptoItem {
  final String symbol;
  final String name;
  final String icon;
  final double price;
  final double change24h;
  final double holdingAmount;
  final double holdingValue;

  const CryptoItem({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.price,
    required this.change24h,
    required this.holdingAmount,
    required this.holdingValue,
  });
}

class StockItem {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final bool isUp;

  const StockItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.isUp,
  });
}

class MockData {
  static const double totalBalance = 19.98;

  static const List<TransactionItem> recentTransactions = [
    TransactionItem(
      id: 'tx-1',
      fromCurrency: 'SGD',
      toCurrency: 'USD',
      fromFlag: '🇸🇬',
      toFlag: '🇺🇸',
      title: 'SGD → USD',
      subtitle: 'Today, 23:27',
      amount: '+US\$1.49',
      secondaryAmount: '-\$2.00',
      isPositive: true,
    ),
    TransactionItem(
      id: 'tx-2',
      fromCurrency: 'USD',
      toCurrency: 'SGD',
      fromFlag: '🇸🇬',
      toFlag: '🇺🇸',
      title: 'SGD → USD',
      subtitle: 'Today, 23:27',
      amount: '-\$2.00',
      secondaryAmount: '+US\$1.49',
      isPositive: false,
    ),
    TransactionItem(
      id: 'tx-3',
      fromCurrency: 'EUR',
      toCurrency: 'USD',
      fromFlag: '🇪🇺',
      toFlag: '🇺🇸',
      title: 'Spotify Premium',
      subtitle: 'Yesterday, 14:10',
      amount: '-\$10.99',
      secondaryAmount: 'Subscription',
      isPositive: false,
    ),
    TransactionItem(
      id: 'tx-4',
      fromCurrency: 'TRY',
      toCurrency: 'USD',
      fromFlag: '🇹🇷',
      toFlag: '🇺🇸',
      title: 'Meryem Güçlü Transfer',
      subtitle: '18 Nov, 09:42',
      amount: '+US\$250.00',
      secondaryAmount: 'Bank Transfer',
      isPositive: true,
    ),
  ];

  static const List<CryptoItem> cryptoAssets = [
    CryptoItem(
      symbol: 'BTC',
      name: 'Bitcoin',
      icon: '₿',
      price: 94820.50,
      change24h: 3.42,
      holdingAmount: 0.012,
      holdingValue: 1137.84,
    ),
    CryptoItem(
      symbol: 'ETH',
      name: 'Ethereum',
      icon: 'Ξ',
      price: 3410.20,
      change24h: -1.15,
      holdingAmount: 0.25,
      holdingValue: 852.55,
    ),
    CryptoItem(
      symbol: 'SOL',
      name: 'Solana',
      icon: '◎',
      price: 182.75,
      change24h: 6.80,
      holdingAmount: 2.50,
      holdingValue: 456.87,
    ),
  ];

  static const List<StockItem> watchlistStocks = [
    StockItem(symbol: 'NVDA', name: 'NVIDIA Corp', price: 142.15, changePercent: 4.82, isUp: true),
    StockItem(symbol: 'AAPL', name: 'Apple Inc', price: 228.40, changePercent: 1.15, isUp: true),
    StockItem(symbol: 'TSLA', name: 'Tesla Inc', price: 214.60, changePercent: -2.30, isUp: false),
    StockItem(symbol: 'S&P 500', name: 'Vanguard Index', price: 586.20, changePercent: 0.74, isUp: true),
  ];
}
