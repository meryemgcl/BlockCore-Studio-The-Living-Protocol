import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class CryptoTradeModal extends StatefulWidget {
  final CryptoItem crypto;

  const CryptoTradeModal({super.key, required this.crypto});

  @override
  State<CryptoTradeModal> createState() => _CryptoTradeModalState();
}

class _CryptoTradeModalState extends State<CryptoTradeModal> {
  double usdToSpend = 10.0;
  bool isBuying = false;

  void _executeBuy() async {
    final state = WalletState.instance;
    if (state.usdBalance < usdToSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz bakiye! Önce kartınızdan para ekleyin.')),
      );
      return;
    }

    setState(() => isBuying = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final success = state.buyCrypto(symbol: widget.crypto.symbol, usdAmount: usdToSpend);
    setState(() => isBuying = false);

    if (success) {
      Navigator.pop(context);
      final tokens = usdToSpend / widget.crypto.price;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF131927),
          content: Text(
            '✓ +${tokens.toStringAsFixed(6)} ${widget.crypto.symbol} Cüzdanınıza Eklendi! (Blok #${state.blockHeight})',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokensToReceive = usdToSpend / widget.crypto.price;

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
                backgroundColor: const Color(0xFF1E2638),
                child: Text(widget.crypto.icon, style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Buy ${widget.crypto.name} (${widget.crypto.symbol})', style: RevolutTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.crypto.price.toStringAsFixed(2)} · ${widget.crypto.change24h >= 0 ? '+' : ''}${widget.crypto.change24h}% (24h)',
                      style: TextStyle(
                        color: widget.crypto.change24h >= 0 ? RevolutTheme.accentGreen : RevolutTheme.accentRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
          // Price Info & Amount Box
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
                    const Text('Amount in USD', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('\$${usdToSpend.toStringAsFixed(2)}', style: RevolutTheme.monoNumeric.copyWith(fontSize: 24)),
                  ],
                ),
                Row(
                  children: [
                    _buildPill(10.0),
                    const SizedBox(width: 6),
                    _buildPill(25.0),
                    const SizedBox(width: 6),
                    _buildPill(50.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Output tokens
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161B26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alınacak Kripto Miktarı:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  '${tokensToReceive.toStringAsFixed(6)} ${widget.crypto.symbol}',
                  style: RevolutTheme.monoNumeric.copyWith(color: RevolutTheme.accentGreen, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RevolutTheme.royalBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: isBuying ? null : _executeBuy,
              child: isBuying
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Confirm Purchase', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(double val) {
    final isSelected = usdToSpend == val;
    return GestureDetector(
      onTap: () => setState(() => usdToSpend = val),
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
