import 'package:flutter/material.dart';
import '../data/currency_models.dart';
import '../data/dataset_repository.dart';
import '../mock/mock_data.dart';

class WalletState extends ChangeNotifier {
  static final WalletState instance = WalletState._internal();
  WalletState._internal() {
    _init();
  }

  final _repo = DatasetRepository.instance;

  double usdBalance = 19.98;
  int blockHeight = 14892;
  String activeAccount = 'Personal · All accounts';
  String baseCurrencyCode = 'USD';
  bool isCardFrozen = false;
  String cardThemeName = 'Premium · Space Grey';
  double monthlySpendingLimit = 2500.0;
  double usedThisMonth = 684.50;

  String revtag = '@meryemgcl';
  String userName = 'Meryem Güçlü';
  String kycTier = 'Tier 2 Identity Verified (Web3 Sovereign)';
  String membershipPlan = 'ULTRA';
  List<String> userPurposes = ['Transfers', 'Metal card', 'Crypto', 'Staking'];

  void updateRevtag(String newTag) {
    revtag = newTag.startsWith('@') ? newTag : '@$newTag';
    notifyListeners();
  }

  void updateKycStatus(String tier) {
    kycTier = tier;
    notifyListeners();
  }

  void updateMembershipPlan(String plan) {
    membershipPlan = plan;
    notifyListeners();
  }

  void updatePurposes(List<String> purposes) {
    userPurposes = List.from(purposes);
    notifyListeners();
  }

  List<TransactionItem> transactions = [];

  List<CryptoItem> cryptoAssets = [
    const CryptoItem(
      symbol: 'BTC',
      name: 'Bitcoin',
      icon: '₿',
      price: 94820.50,
      change24h: 3.42,
      holdingAmount: 0.012,
      holdingValue: 1137.84,
    ),
    const CryptoItem(
      symbol: 'ETH',
      name: 'Ethereum',
      icon: 'Ξ',
      price: 3410.20,
      change24h: -1.15,
      holdingAmount: 0.25,
      holdingValue: 852.55,
    ),
    const CryptoItem(
      symbol: 'SOL',
      name: 'Solana',
      icon: '◎',
      price: 182.75,
      change24h: 6.80,
      holdingAmount: 2.50,
      holdingValue: 456.87,
    ),
  ];

  Future<void> _init() async {
    transactions = await _repo.loadLedger();
    final savedBal = await _repo.loadBalance();
    if (savedBal != null) usdBalance = savedBal;
    monthlySpendingLimit = await _repo.loadSpendingLimit();
    notifyListeners();
  }

  Currency get baseCurrency => CurrencyRegistry.find(baseCurrencyCode);

  double get displayBalance {
    return CurrencyRegistry.convert(amount: usdBalance, from: 'USD', to: baseCurrencyCode);
  }

  void setBaseCurrency(String code) {
    baseCurrencyCode = code;
    notifyListeners();
  }

  void setSpendingLimit(double newLimit) {
    monthlySpendingLimit = newLimit;
    _repo.saveSpendingLimit(newLimit);
    notifyListeners();
  }

  void addDeposit(double amount, String currencyCode) {
    final amountInUsd = CurrencyRegistry.convert(amount: amount, from: currencyCode, to: 'USD');
    usdBalance += amountInUsd;
    blockHeight += 1;
    
    final cur = CurrencyRegistry.find(currencyCode);
    transactions.insert(
      0,
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        fromCurrency: currencyCode,
        toCurrency: 'USD',
        fromFlag: cur.flag,
        toFlag: '🇺🇸',
        title: '$currencyCode Deposit (Mint)',
        subtitle: 'Just now · Block #$blockHeight',
        amount: '+${cur.symbol}${amount.toStringAsFixed(2)}',
        secondaryAmount: 'On-Chain Mint',
        isPositive: true,
      ),
    );
    _repo.saveBalance(usdBalance);
    _repo.saveLedger(transactions);
    notifyListeners();
  }

  bool sendMoney({
    required String recipientName,
    required double amount,
    String currencyCode = 'USD',
  }) {
    final amountInUsd = CurrencyRegistry.convert(amount: amount, from: currencyCode, to: 'USD');
    if (usdBalance < amountInUsd) return false;

    usdBalance -= amountInUsd;
    usedThisMonth += amountInUsd;
    blockHeight += 1;

    final cur = CurrencyRegistry.find(currencyCode);
    transactions.insert(
      0,
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        fromCurrency: 'USD',
        toCurrency: currencyCode,
        fromFlag: '🇺🇸',
        toFlag: '👤',
        title: 'Sent to $recipientName',
        subtitle: 'Just now · Block #$blockHeight',
        amount: '-${cur.symbol}${amount.toStringAsFixed(2)}',
        secondaryAmount: 'P2P Transfer',
        isPositive: false,
      ),
    );
    _repo.saveBalance(usdBalance);
    _repo.saveLedger(transactions);
    notifyListeners();
    return true;
  }

  bool executeCurrencyExchange({
    required String fromCode,
    required String toCode,
    required double fromAmount,
    required double toAmount,
  }) {
    final fromInUsd = CurrencyRegistry.convert(amount: fromAmount, from: fromCode, to: 'USD');
    if (usdBalance < fromInUsd) return false;

    blockHeight += 1;
    final fromCur = CurrencyRegistry.find(fromCode);
    final toCur = CurrencyRegistry.find(toCode);

    transactions.insert(
      0,
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        fromCurrency: fromCode,
        toCurrency: toCode,
        fromFlag: fromCur.flag,
        toFlag: toCur.flag,
        title: '$fromCode ➔ $toCode Exchange',
        subtitle: 'Just now · Block #$blockHeight',
        amount: '+${toCur.symbol}${toAmount.toStringAsFixed(2)}',
        secondaryAmount: '-${fromCur.symbol}${fromAmount.toStringAsFixed(2)}',
        isPositive: true,
      ),
    );
    _repo.saveLedger(transactions);
    notifyListeners();
    return true;
  }

  bool buyCrypto({required String symbol, required double usdAmount}) {
    if (usdBalance < usdAmount) return false;
    usdBalance -= usdAmount;
    usedThisMonth += usdAmount;
    blockHeight += 1;

    final index = cryptoAssets.indexWhere((c) => c.symbol == symbol);
    if (index >= 0) {
      final old = cryptoAssets[index];
      final boughtAmount = usdAmount / old.price;
      final newAmount = old.holdingAmount + boughtAmount;
      final newValue = newAmount * old.price;
      cryptoAssets[index] = CryptoItem(
        symbol: old.symbol,
        name: old.name,
        icon: old.icon,
        price: old.price,
        change24h: old.change24h,
        holdingAmount: newAmount,
        holdingValue: newValue,
      );
    }

    transactions.insert(
      0,
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        fromCurrency: 'USD',
        toCurrency: symbol,
        fromFlag: '🇺🇸',
        toFlag: '🪙',
        title: 'Bought $symbol',
        subtitle: 'Just now · Block #$blockHeight',
        amount: '-\$${usdAmount.toStringAsFixed(2)}',
        secondaryAmount: '+$symbol Exchange',
        isPositive: false,
      ),
    );

    _repo.saveBalance(usdBalance);
    _repo.saveLedger(transactions);
    notifyListeners();
    return true;
  }

  void toggleCardFreeze() {
    isCardFrozen = !isCardFrozen;
    notifyListeners();
  }

  void setCardTheme(String name) {
    cardThemeName = name;
    notifyListeners();
  }

  void setActiveAccount(String account) {
    activeAccount = account;
    notifyListeners();
  }
}
