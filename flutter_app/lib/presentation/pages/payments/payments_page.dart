import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../modals/search_modal.dart';
import '../../modals/send_money_modal.dart';
import '../../modals/split_bill_modal.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  void _openSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        onSelectTransaction: (tx) {},
      ),
    );
  }

  void _openSendModal(BuildContext context, String name, String initial, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendMoneyModal(
        recipientName: name,
        initial: initial,
        avatarColor: color,
      ),
    );
  }

  void _openSplitBillModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SplitBillModal(),
    );
  }

  void _showQrCodeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131927),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ödeme Al (QR Kod)', style: RevolutTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Para veya token almak için bu kodu taratın', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text('0x71C98B2a4F9e8C12...4E390', style: TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': 'Alice', 'initial': 'A', 'cur': 'USD 🇺🇸', 'color': const Color(0xFF0D47A1)},
      {'name': 'Bob', 'initial': 'B', 'cur': 'EUR 🇪🇺', 'color': const Color(0xFF1B5E20)},
      {'name': 'Mehmet', 'initial': 'M', 'cur': 'TRY 🇹🇷', 'color': const Color(0xFFE65100)},
      {'name': 'Emma', 'initial': 'E', 'cur': 'GBP 🇬🇧', 'color': const Color(0xFF4A148C)},
      {'name': 'Kenji', 'initial': 'K', 'cur': 'JPY 🇯🇵', 'color': const Color(0xFFB71C1C)},
    ];

    return Scaffold(
      backgroundColor: RevolutTheme.darkBackground,
      appBar: AppBar(
        title: Text('Payments & Transfer', style: RevolutTheme.titleMedium),
        actions: [
          IconButton(
            onPressed: () => _showQrCodeModal(context),
            icon: const Icon(AppIcons.qrCode, size: 20),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yeni On-Chain Kişi Ekleme Ekranı')),
              );
            },
            icon: const Icon(AppIcons.userPlus, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Search box
          GestureDetector(
            onTap: () => _openSearchModal(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: RevolutTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Row(
                children: [
                  Icon(AppIcons.search, color: Colors.white54, size: 18),
                  SizedBox(width: 10),
                  Text('Name, @Revtag, phone or card number',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Friends & Contacts (Tap to Send)', style: RevolutTheme.titleMedium.copyWith(fontSize: 16)),
          const SizedBox(height: 14),
          // Contacts Row
          SizedBox(
            height: 95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (ctx, i) {
                final c = contacts[i];
                return GestureDetector(
                  onTap: () => _openSendModal(
                    context,
                    c['name'] as String,
                    c['initial'] as String,
                    c['color'] as Color,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: c['color'] as Color,
                        child: Text(
                          c['initial'] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(c['name'] as String, style: RevolutTheme.caption.copyWith(color: Colors.white)),
                      Text(c['cur'] as String, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Transfer Options', style: RevolutTheme.titleMedium.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: RevolutTheme.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  AppIcons.send,
                  'Bank Transfer (SWIFT / FAST)',
                  'Send money globally in USD, EUR, TRY, GBP',
                  () => _openSendModal(context, 'Bank Hesabı', 'B', const Color(0xFF0D47A1)),
                ),
                const Divider(height: 1, indent: 60),
                _buildActionTile(
                  context,
                  AppIcons.splitBill,
                  'Split Bill Calculator',
                  'Dine & travel calculator with tip & multi-share',
                  () => _openSplitBillModal(context),
                ),
                const Divider(height: 1, indent: 60),
                _buildActionTile(
                  context,
                  AppIcons.scheduled,
                  'Scheduled Standing Orders',
                  'Automated weekly & monthly on-chain transfers',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Düzenli Ödeme Emri Modülü Aktif')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1E2638),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: RevolutTheme.caption),
      trailing: const Icon(AppIcons.chevronRight, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}
