import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../mock/mock_data.dart';

class DatasetRepository {
  static final DatasetRepository instance = DatasetRepository._internal();
  DatasetRepository._internal();

  static const String _txKey = 'blockcore_ledger_dataset_v1';
  static const String _balanceKey = 'blockcore_balance_v1';
  static const String _limitKey = 'blockcore_card_limit_v1';

  final List<TransactionItem> _defaultSeedDataset = [
    const TransactionItem(
      id: 'tx-101',
      fromCurrency: 'SGD',
      toCurrency: 'USD',
      fromFlag: '🇸🇬',
      toFlag: '🇺🇸',
      title: 'SGD → USD Exchange',
      subtitle: 'Today, 23:27 · Block #14892',
      amount: '+US\$1.49',
      secondaryAmount: '-\$2.00 SGD',
      isPositive: true,
    ),
    const TransactionItem(
      id: 'tx-102',
      fromCurrency: 'USD',
      toCurrency: 'USD',
      fromFlag: '🇺🇸',
      toFlag: '☕',
      title: 'Starbucks Reserve London',
      subtitle: 'Today, 18:40 · Dining',
      amount: '-\$6.80',
      secondaryAmount: 'Card ··4892',
      isPositive: false,
    ),
    const TransactionItem(
      id: 'tx-103',
      fromCurrency: 'TRY',
      toCurrency: 'USD',
      fromFlag: '🇹🇷',
      toFlag: '🇺🇸',
      title: 'Meryem Güçlü FAST Havale',
      subtitle: 'Yesterday, 14:15 · Deposit',
      amount: '+US\$350.00',
      secondaryAmount: '₺12,075 TRY',
      isPositive: true,
    ),
    const TransactionItem(
      id: 'tx-104',
      fromCurrency: 'USD',
      toCurrency: 'BTC',
      fromFlag: '🇺🇸',
      toFlag: '🪙',
      title: 'Binance Web3 Vault Staking',
      subtitle: '20 Nov, 09:12 · Staking Yield',
      amount: '+US\$42.50',
      secondaryAmount: '+0.00045 BTC',
      isPositive: true,
    ),
    const TransactionItem(
      id: 'tx-105',
      fromCurrency: 'USD',
      toCurrency: 'USD',
      fromFlag: '🇺🇸',
      toFlag: '💻',
      title: 'Apple Store 5th Ave',
      subtitle: '19 Nov, 16:30 · Electronics',
      amount: '-\$129.00',
      secondaryAmount: 'Apple Pay ··4892',
      isPositive: false,
    ),
    const TransactionItem(
      id: 'tx-106',
      fromCurrency: 'EUR',
      toCurrency: 'USD',
      fromFlag: '🇪🇺',
      toFlag: '✈️',
      title: 'Singapore Airlines Flight',
      subtitle: '18 Nov, 11:20 · Travel',
      amount: '-\$480.00',
      secondaryAmount: '-€456.00 EUR',
      isPositive: false,
    ),
    const TransactionItem(
      id: 'tx-107',
      fromCurrency: 'GBP',
      toCurrency: 'USD',
      fromFlag: '🇬🇧',
      toFlag: '💼',
      title: 'Global Tech Salary Deposit',
      subtitle: '15 Nov, 08:00 · Payroll',
      amount: '+US\$3,200.00',
      secondaryAmount: '+£2,528.00 GBP',
      isPositive: true,
    ),
    const TransactionItem(
      id: 'tx-108',
      fromCurrency: 'USD',
      toCurrency: 'USD',
      fromFlag: '🇺🇸',
      toFlag: '🎬',
      title: 'Netflix 4K Premium',
      subtitle: '14 Nov, 03:00 · Subscription',
      amount: '-\$19.99',
      secondaryAmount: 'Auto-Debit',
      isPositive: false,
    ),
  ];

  Future<List<TransactionItem>> loadLedger() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_txKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return List.from(_defaultSeedDataset);
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) {
        return TransactionItem(
          id: item['id'] as String,
          fromCurrency: item['fromCurrency'] as String,
          toCurrency: item['toCurrency'] as String,
          fromFlag: item['fromFlag'] as String,
          toFlag: item['toFlag'] as String,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          amount: item['amount'] as String,
          secondaryAmount: item['secondaryAmount'] as String,
          isPositive: item['isPositive'] as bool? ?? false,
        );
      }).toList();
    } catch (_) {
      return List.from(_defaultSeedDataset);
    }
  }

  Future<void> saveLedger(List<TransactionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((t) => {
      'id': t.id,
      'fromCurrency': t.fromCurrency,
      'toCurrency': t.toCurrency,
      'fromFlag': t.fromFlag,
      'toFlag': t.toFlag,
      'title': t.title,
      'subtitle': t.subtitle,
      'amount': t.amount,
      'secondaryAmount': t.secondaryAmount,
      'isPositive': t.isPositive,
    }).toList();
    await prefs.setString(_txKey, jsonEncode(list));
  }

  Future<double?> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey);
  }

  Future<void> saveBalance(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, val);
  }

  Future<double> loadSpendingLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_limitKey) ?? 2500.0;
  }

  Future<void> saveSpendingLimit(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_limitKey, val);
  }
}
