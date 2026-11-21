import 'package:flutter/material.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class SpendingLimitModal extends StatefulWidget {
  const SpendingLimitModal({super.key});

  @override
  State<SpendingLimitModal> createState() => _SpendingLimitModalState();
}

class _SpendingLimitModalState extends State<SpendingLimitModal> {
  late double limit;

  @override
  void initState() {
    super.initState();
    limit = WalletState.instance.monthlySpendingLimit;
  }

  @override
  Widget build(BuildContext context) {
    final state = WalletState.instance;
    final used = state.usedThisMonth;
    final percentage = (used / limit).clamp(0.0, 1.0);

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
              Text('Monthly Spending Limit', style: RevolutTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Banka kartınız ve Web3 cüzdanınız üzerinden ay boyunca yapılabilecek maksimum harcama tavanını belirleyin.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          // Current Usage Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kullanılan: \$${used.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Limit: \$${limit.toStringAsFixed(0)}', style: RevolutTheme.monoNumeric.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 0.85 ? RevolutTheme.accentRed : RevolutTheme.royalBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kalan Kullanılabilir Limit: \$${(limit - used).clamp(0.0, double.infinity).toStringAsFixed(2)}',
                  style: const TextStyle(color: RevolutTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Limit Ayarı:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              Text('\$${limit.toStringAsFixed(0)}', style: RevolutTheme.heroBalance.copyWith(fontSize: 22)),
            ],
          ),
          Slider(
            value: limit,
            min: 500.0,
            max: 10000.0,
            divisions: 19,
            activeColor: RevolutTheme.royalBlue,
            inactiveColor: Colors.white12,
            onChanged: (val) {
              setState(() => limit = val);
            },
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
              onPressed: () {
                state.setSpendingLimit(limit);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Aylık harcama limiti \$${limit.toStringAsFixed(0)} olarak güncellendi!')),
                );
              },
              child: const Text('Limiti Kaydet & Uygula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
