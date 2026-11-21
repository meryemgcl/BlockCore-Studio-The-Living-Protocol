import 'package:flutter/material.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/hold_to_sign_button.dart';

class SendMoneyModal extends StatefulWidget {
  final String recipientName;
  final String initial;
  final Color avatarColor;

  const SendMoneyModal({
    super.key,
    required this.recipientName,
    required this.initial,
    required this.avatarColor,
  });

  @override
  State<SendMoneyModal> createState() => _SendMoneyModalState();
}

class _SendMoneyModalState extends State<SendMoneyModal> {
  double sendAmount = 5.0;
  bool isFastGas = true;

  Future<void> _executeOnChainSend() async {
    final state = WalletState.instance;
    if (state.usdBalance < sendAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye! Lütfen önce hesabınıza bakiye ekleyin.')),
      );
      return;
    }

    final success = state.sendMoney(recipientName: widget.recipientName, amount: sendAmount);

    if (success && mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF131927),
          content: Text(
            '✓ \$${sendAmount.toStringAsFixed(2)} ${widget.recipientName}\'a Gönderildi! (Blok #${state.blockHeight} Onaylandı)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: widget.avatarColor,
                child: Text(
                  widget.initial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send to ${widget.recipientName}', style: RevolutTheme.titleMedium),
                    const SizedBox(height: 2),
                    const Text('0x3A9F...882c (Verified Contact)', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Amount Selector Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const Text('Transfer Amount', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('\$${sendAmount.toStringAsFixed(2)}', style: RevolutTheme.monoNumeric.copyWith(fontSize: 26)),
                  ],
                ),
                Row(
                  children: [
                    _buildAmountPill(5.0),
                    const SizedBox(width: 6),
                    _buildAmountPill(10.0),
                    const SizedBox(width: 6),
                    _buildAmountPill(25.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Cryptographic Signature Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.lock, color: RevolutTheme.accentGreen, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'HMAC-SHA256 Dijital İmza ile Yetkilendirildi',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                Text('0x9F4A...7B1C', style: RevolutTheme.monoNumeric.copyWith(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          HoldToSignButton(
            label: 'Basılı Tut ve İmzala (\$${sendAmount.toStringAsFixed(2)})',
            onSignComplete: _executeOnChainSend,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPill(double val) {
    final isSelected = sendAmount == val;
    return GestureDetector(
      onTap: () => setState(() => sendAmount = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '\$${val.toInt()}',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
