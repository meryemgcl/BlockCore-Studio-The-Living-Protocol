import 'package:flutter/material.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/wallet_state.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../modals/crypto_trade_modal.dart';
import '../../modals/exchange_modal.dart';
import '../../modals/notification_modal.dart';
import '../../modals/search_modal.dart';
import '../../widgets/interactive_chart_widget.dart';

class CryptoPage extends StatelessWidget {
  const CryptoPage({super.key});

  void _openTradeModal(BuildContext context, CryptoItem crypto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CryptoTradeModal(crypto: crypto),
    );
  }

  void _openSwapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExchangeModal(),
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationModal(onClearBadge: () {}),
    );
  }

  void _openSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        onSelectTransaction: (tx) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = WalletState.instance;

    return ListenableBuilder(
      listenable: walletState,
      builder: (context, _) {
        final totalCryptoVal = walletState.cryptoAssets.fold<double>(
          0.0,
          (sum, c) => sum + c.holdingValue,
        );

        return Scaffold(
          backgroundColor: RevolutTheme.darkBackground,
          appBar: AppBar(
            title: Text('Crypto Portfolio', style: RevolutTheme.titleMedium),
            actions: [
              IconButton(
                onPressed: () => _openNotifications(context),
                icon: const Icon(AppIcons.bell, size: 20),
              ),
              IconButton(
                onPressed: () => _openSearch(context),
                icon: const Icon(AppIcons.search, size: 20),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildCryptoBalanceCard(totalCryptoVal),
              const SizedBox(height: 16),
              const InteractiveChartWidget(
                title: 'Bitcoin (BTC) / On-Chain Realtime 24h Feed',
                lineColor: RevolutTheme.royalBlue,
                dataPoints: [62400.0, 62850.0, 62100.0, 63200.0, 63900.0, 63400.0, 64200.0, 64800.0, 64500.0, 65120.0, 65890.0, 66400.0],
                baseCurrencySymbol: '\$',
              ),
              const SizedBox(height: 20),
              _buildCryptoActionButtons(context, walletState),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Assets (Tap to Trade)', style: RevolutTheme.titleMedium.copyWith(fontSize: 16)),
                  Text('See all (${walletState.cryptoAssets.length})', style: RevolutTheme.caption.copyWith(color: RevolutTheme.royalBlue)),
                ],
              ),
              const SizedBox(height: 12),
              _buildCryptoAssetList(context, walletState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCryptoBalanceCard(double totalCryptoVal) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Crypto Balance', style: RevolutTheme.caption),
          const SizedBox(height: 6),
          Text('\$${totalCryptoVal.toStringAsFixed(2)}', style: RevolutTheme.heroBalance.copyWith(fontSize: 34)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RevolutTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.trendUp, color: RevolutTheme.accentGreen, size: 14),
                    const SizedBox(width: 4),
                    Text('+4.8% Today',
                        style: RevolutTheme.caption.copyWith(
                            color: RevolutTheme.accentGreen, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('+\$112.40 profit', style: RevolutTheme.caption.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoActionButtons(BuildContext context, WalletState walletState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: RevolutTheme.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(AppIcons.plus, size: 18),
            label: const Text('Buy Crypto', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => _openTradeModal(context, walletState.cryptoAssets.first),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2638),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(AppIcons.move, size: 18),
            label: const Text('Swap / Sell', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => _openSwapModal(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoAssetList(BuildContext context, WalletState walletState) {
    return Container(
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: walletState.cryptoAssets.map((crypto) {
          final isUp = crypto.change24h >= 0;
          return ListTile(
            onTap: () => _openTradeModal(context, crypto),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E2638),
              child: Text(
                crypto.icon,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(crypto.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              '${crypto.holdingAmount.toStringAsFixed(4)} ${crypto.symbol}',
              style: RevolutTheme.caption,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${crypto.holdingValue.toStringAsFixed(2)}', style: RevolutTheme.monoNumeric),
                Text(
                  '${isUp ? '+' : ''}${crypto.change24h}%',
                  style: TextStyle(
                    color: isUp ? RevolutTheme.accentGreen : RevolutTheme.accentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
