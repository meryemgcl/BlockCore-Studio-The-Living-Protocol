import 'package:flutter/material.dart';
import '../../core/data/currency_models.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class ExchangeModal extends StatefulWidget {
  const ExchangeModal({super.key});

  @override
  State<ExchangeModal> createState() => _ExchangeModalState();
}

class _ExchangeModalState extends State<ExchangeModal> {
  double fromAmount = 10.0;
  String fromCode = 'USD';
  String toCode = 'TRY';
  bool isExchanging = false;

  void _executeExchange() async {
    final state = WalletState.instance;
    final toAmount = CurrencyRegistry.convert(amount: fromAmount, from: fromCode, to: toCode);

    setState(() => isExchanging = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final success = state.executeCurrencyExchange(
      fromCode: fromCode,
      toCode: toCode,
      fromAmount: fromAmount,
      toAmount: toAmount,
    );
    setState(() => isExchanging = false);

    if (success) {
      Navigator.pop(context);
      final toCur = CurrencyRegistry.find(toCode);
      final fromCur = CurrencyRegistry.find(fromCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF131927),
          content: Text(
            '✓ Takas Başarılı: ${fromCur.symbol}${fromAmount.toStringAsFixed(2)} $fromCode ➔ ${toCur.symbol}${toAmount.toStringAsFixed(2)} $toCode (Blok #${state.blockHeight})',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye! Lütfen önce hesabınıza para ekleyin.')),
      );
    }
  }

  void _showCurrencyPicker({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131927),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isFrom ? 'Satılacak Para Birimi' : 'Alınacak Para Birimi', style: RevolutTheme.titleMedium),
            const SizedBox(height: 16),
            ...CurrencyRegistry.currencies.map((c) {
              final isCurrent = (isFrom ? fromCode : toCode) == c.code;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                title: Text('${c.code} · ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('1 USD = ${c.rateToUsd} ${c.code}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: isCurrent ? const Icon(Icons.check, color: RevolutTheme.accentGreen) : null,
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      fromCode = c.code;
                    } else {
                      toCode = c.code;
                    }
                  });
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromCur = CurrencyRegistry.find(fromCode);
    final toCur = CurrencyRegistry.find(toCode);
    final toAmount = CurrencyRegistry.convert(amount: fromAmount, from: fromCode, to: toCode);
    final rate = CurrencyRegistry.convert(amount: 1.0, from: fromCode, to: toCode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF131927),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Instant Currency Exchange', style: RevolutTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // From Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You Sell', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${fromCur.symbol}${fromAmount.toStringAsFixed(2)}', style: RevolutTheme.monoNumeric.copyWith(fontSize: 22)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showCurrencyPicker(isFrom: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('${fromCur.flag}  ${fromCur.code}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Exchange Icon
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.move, color: Colors.white, size: 16),
            ),
          ),
          // To Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You Get', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('${toCur.symbol}${toAmount.toStringAsFixed(2)}',
                        style: RevolutTheme.monoNumeric.copyWith(fontSize: 22, color: RevolutTheme.accentGreen)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showCurrencyPicker(isFrom: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('${toCur.flag}  ${toCur.code}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1 $fromCode = ${rate.toStringAsFixed(4)} $toCode · Canlı Kur · Sıfır Komisyon',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: isExchanging ? null : _executeExchange,
              child: isExchanging
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Confirm Exchange', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
