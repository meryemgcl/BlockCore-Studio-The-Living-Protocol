import 'package:flutter/material.dart';
import '../../../core/state/wallet_state.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../modals/spending_limit_modal.dart';
import 'card_customizer_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool onlinePayments = true;
  bool showCardDetails = false;
  bool isAddedToAppleWallet = false;
  final walletState = WalletState.instance;

  void _openSpendingLimitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SpendingLimitModal(),
    );
  }

  void _showTerminateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131927),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: RevolutTheme.accentRed, size: 24),
            SizedBox(width: 8),
            Text('Kartı Kalıcı Olarak İptal Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bu kart kalıcı olarak bloke edilecek ve yeni bir Web3 soğuk cüzdan donanım anahtarı üretilecektir. Devam etmek istiyor musunuz?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RevolutTheme.accentRed),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kart iptal edildi ve yeni kart talebiniz oluşturuldu.')),
              );
            },
            child: const Text('Evet, Kartı İptal Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: walletState,
      builder: (context, _) {
        final isFrozen = walletState.isCardFrozen;

        return Scaffold(
          backgroundColor: RevolutTheme.darkBackground,
          appBar: AppBar(
            title: Text('Cards & Security', style: RevolutTheme.titleMedium),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CardCustomizerPage()),
                  );
                },
                icon: const Icon(AppIcons.plus, size: 20),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildDebitCard(isFrozen),
              const SizedBox(height: 24),
              _buildCardQuickActions(isFrozen),
              const SizedBox(height: 20),
              // Apple / Google Wallet Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => isAddedToAppleWallet = !isAddedToAppleWallet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isAddedToAppleWallet ? 'Kart Apple Wallet\'a eklendi ✓' : 'Kart Apple Wallet\'tan çıkarıldı')),
                    );
                  },
                  icon: Icon(isAddedToAppleWallet ? Icons.check_circle : Icons.wallet, color: isAddedToAppleWallet ? RevolutTheme.accentGreen : Colors.white, size: 20),
                  label: Text(
                    isAddedToAppleWallet ? 'Apple Wallet ile Eşleşti ✓' : 'Add to Apple Wallet',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Card Settings & Security', style: RevolutTheme.titleMedium.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              _buildSettingsGroup(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebitCard(bool isFrozen) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isFrozen
            ? const LinearGradient(
                colors: [Color(0xFF2C394E), Color(0xFF1E2638)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF0F172A), Color(0xFF020617)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFrozen ? Colors.cyan.withOpacity(0.5) : Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFrozen ? Colors.cyan.withOpacity(0.15) : const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revolut',
                style: RevolutTheme.titleMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              if (isFrozen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan),
                  ),
                  child: const Row(
                    children: [
                      Icon(AppIcons.freeze, color: Colors.cyan, size: 12),
                      SizedBox(width: 4),
                      Text('FROZEN', style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                const Icon(AppIcons.contactless, color: Colors.white70, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showCardDetails ? '4532  8910  2341  4892' : '••••  ••••  ••••  4892',
                style: RevolutTheme.monoNumeric.copyWith(fontSize: 18, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MERYEM GÜÇLÜ', style: RevolutTheme.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(showCardDetails ? '09/28 · CVV 742' : '09/28', style: RevolutTheme.monoNumeric.copyWith(fontSize: 13)),
                  const Text('VISA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardQuickActions(bool isFrozen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAction(
          icon: isFrozen ? AppIcons.unfreeze : AppIcons.freeze,
          label: isFrozen ? 'Unfreeze' : 'Freeze',
          color: isFrozen ? Colors.cyan : Colors.white,
          onTap: () {
            walletState.toggleCardFreeze();
          },
        ),
        _buildQuickAction(
          icon: showCardDetails ? AppIcons.eyeOff : AppIcons.eye,
          label: showCardDetails ? 'Hide' : 'Details',
          color: Colors.white,
          onTap: () {
            setState(() => showCardDetails = !showCardDetails);
          },
        ),
        _buildQuickAction(
          icon: AppIcons.settings,
          label: 'Customise',
          color: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardCustomizerPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: RevolutTheme.cardSurface,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: RevolutTheme.caption.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup() {
    return Container(
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(AppIcons.globe, color: Colors.white70),
            title: const Text('Online Web3 Transactions'),
            subtitle: const Text('Smart contract & dApp card signing'),
            value: onlinePayments,
            activeColor: RevolutTheme.royalBlue,
            onChanged: (v) => setState(() => onlinePayments = v),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(AppIcons.lock, color: Colors.white70),
            title: const Text('Monthly Spending Limit'),
            subtitle: Text('\$${walletState.monthlySpendingLimit.toStringAsFixed(0)} / month (Değiştirmek için dokunun)'),
            trailing: const Icon(AppIcons.chevronRight, size: 16),
            onTap: _openSpendingLimitModal,
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(AppIcons.trash, color: RevolutTheme.accentRed),
            title: const Text('Terminate Card', style: TextStyle(color: RevolutTheme.accentRed)),
            subtitle: const Text('Permanently block and reissue hardware key'),
            onTap: _showTerminateDialog,
          ),
        ],
      ),
    );
  }
}
