import 'package:flutter/material.dart';
import '../../../core/data/currency_models.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/state/wallet_state.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../modals/analytics_modal.dart';
import '../../modals/exchange_modal.dart';
import '../../modals/notification_modal.dart';
import '../../modals/profile_modal.dart';
import '../../modals/proof_of_reserves_modal.dart';
import '../../modals/search_modal.dart';
import '../../widgets/animated_balance_text.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/transaction_tile.dart';
import '../add_money/add_money_page.dart';
import '../cards/card_customizer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final walletState = WalletState.instance;
  bool _hasUnreadNotifications = true;

  void _openProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileModal(),
    );
  }

  void _openNotificationModal() {
    setState(() => _hasUnreadNotifications = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationModal(
        onClearBadge: () {
          setState(() => _hasUnreadNotifications = false);
        },
      ),
    );
  }

  void _openSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        onSelectTransaction: (tx) => _showTransactionDetails(tx),
      ),
    );
  }

  void _openAnalyticsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AnalyticsModal(currentBlockHeight: walletState.blockHeight),
    );
  }

  void _openProofOfReservesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProofOfReservesModal(),
    );
  }

  void _openExchangeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExchangeModal(),
    );
  }

  void _openAccountSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131927),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ana Para Birimi & Hesap Değiştir', style: RevolutTheme.titleMedium),
              const SizedBox(height: 16),
              ...CurrencyRegistry.currencies.map((c) {
                final isSelected = walletState.baseCurrencyCode == c.code;
                final convertedBal = CurrencyRegistry.convert(amount: walletState.usdBalance, from: 'USD', to: c.code);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                  title: Text('${c.code} · ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('1 USD = ${c.rateToUsd} ${c.code}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: Text(
                    '${c.symbol}${convertedBal.toStringAsFixed(2)}',
                    style: RevolutTheme.monoNumeric.copyWith(
                      fontSize: 14,
                      color: isSelected ? RevolutTheme.accentGreen : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    walletState.setBaseCurrency(c.code);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ana para birimi ${c.code} (${c.name}) olarak ayarlandı!')),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openAddMoneyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMoneyPage(
          onAddMoney: (amount, currency) {
            walletState.addDeposit(amount, currency);
          },
        ),
      ),
    );
  }

  void _openCardCustomizer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CardCustomizerPage(),
      ),
    );
  }

  void _showTransactionDetails(TransactionItem tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131927),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('On-Chain İşlem Fişi', style: RevolutTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: RevolutTheme.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('CONFIRMED',
                        style: TextStyle(color: RevolutTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildReceiptRow('İşlem Tipi:', tx.title),
              _buildReceiptRow('Tutar:', tx.amount),
              _buildReceiptRow('Tarih / Saat:', tx.subtitle),
              _buildReceiptRow('Blok Numarası:', '#${walletState.blockHeight}'),
              _buildReceiptRow('Tx Hash:', '0x7f2a...89b4e1 (SHA-256)'),
              _buildReceiptRow('Merkle Root:', '0x3d9c...41e8f2'),
              _buildReceiptRow('Gas Ücreti:', '0.00012 ETH (No Fee)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: RevolutTheme.monoNumeric.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: walletState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: RevolutTheme.darkBackground,
          body: Stack(
            children: [
              // Royal Blue Top Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RevolutTheme.heroGradient,
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    _buildTopAppBar(),
                    const SizedBox(height: 12),
                    _buildHeroBalance(),
                    const SizedBox(height: 28),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildProofOfReservesBanner(),
                    const SizedBox(height: 20),
                    _buildRecentActivityCard(),
                    const SizedBox(height: 16),
                    _buildProductsForYou(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar -> Opens Profile Modal!
          GestureDetector(
            onTap: _openProfileModal,
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF2C394E),
                  child: Text(
                    'MG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: RevolutTheme.accentRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: RevolutTheme.royalBlue, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Search Pill -> Opens Interactive Search Modal!
          Expanded(
            child: GestureDetector(
              onTap: _openSearchModal,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.search, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Search · Block #${walletState.blockHeight}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Notification Bell
          IconButton(
            onPressed: _openNotificationModal,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(AppIcons.bell, color: Colors.white, size: 20),
                if (_hasUnreadNotifications)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: RevolutTheme.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Analytics Icon -> Opens Network Telemetry!
          IconButton(
            onPressed: _openAnalyticsModal,
            icon: const Icon(AppIcons.analytics, color: Colors.white, size: 20),
          ),
          // Card Icon -> Opens Card Customizer!
          IconButton(
            onPressed: _openCardCustomizer,
            icon: const Icon(AppIcons.cardOutline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBalance() {
    final cur = walletState.baseCurrency;
    final converted = walletState.displayBalance;

    return Column(
      children: [
        Text(
          'Personal · ${cur.code} (${cur.name})',
          style: RevolutTheme.caption.copyWith(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBalanceText(
          value: converted,
          symbol: cur.symbol,
        ),
        const SizedBox(height: 12),
        // Accounts Pill Button -> Opens Account Switcher!
        GestureDetector(
          onTap: _openAccountSwitcher,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cur.flag, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  '${cur.code} Accounts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Pagination Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 5, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Container(width: 5, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: AppIcons.plus,
            label: 'Add money',
            onTap: _openAddMoneyPage,
          ),
          QuickActionButton(
            icon: AppIcons.move,
            label: 'Move',
            onTap: _openExchangeModal,
          ),
          QuickActionButton(
            icon: Icons.verified_user_outlined,
            label: 'PoR Vault',
            onTap: _openProofOfReservesModal,
          ),
          QuickActionButton(
            icon: AppIcons.more,
            label: 'More',
            onTap: _openCardCustomizer,
          ),
        ],
      ),
    );
  }

  Widget _buildProofOfReservesBanner() {
    return GestureDetector(
      onTap: _openProofOfReservesModal,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131F33),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: RevolutTheme.accentGreen.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: RevolutTheme.accentGreen.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: RevolutTheme.accentGreen.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: RevolutTheme.accentGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Proof of Reserves (PoR)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: RevolutTheme.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('%102.0 Solvent', style: TextStyle(color: RevolutTheme.accentGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Kriptografik Merkle Tree ile %100 Karşılık Denetimi',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          ...walletState.transactions.map(
            (tx) => TransactionTile(
              item: tx,
              onTap: () => _showTransactionDetails(tx),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _openSearchModal,
              child: const Text(
                'See all',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsForYou() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF131927),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Staking & Web3 Vaults', style: RevolutTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'Boştaki varlıklarınızı Proof-of-Stake konsensüsüne stake ederek yıllık %5.4 APY getiri elde edin.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.bolt, color: Colors.white)),
                  title: const Text('Alpha Doğrulayıcı Düğümüne Stake Et'),
                  subtitle: const Text('Minimum 10 BLC · 0 Kilitleme Süresi'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alpha Node Staking Havuzu Açıldı!')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: RevolutTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Smart Contracts & Staking',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const Icon(AppIcons.chevronRight, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}
