import 'package:flutter/material.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../pages/onboarding/onboarding_wizard_page.dart';
import 'notification_modal.dart';
import 'proof_of_reserves_modal.dart';

class ProfileModal extends StatefulWidget {
  const ProfileModal({super.key});

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  String selectedNetwork = 'BlockCore Testnet v1.0 (P2P)';
  bool biometricEnabled = true;

  void _showSeedPhraseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131927),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key, color: Colors.amber, size: 22),
            SizedBox(width: 10),
            Text('12 Kelimelik Kurtarma Anahtarı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu kelimeler cüzdanınızın tek kurtarma yoludur. Kimseyle paylaşmayın!',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '1. galaxy', '2. protocol', '3. velvet', '4. quantum',
                '5. anchor', '6. block', '7. summit', '8. crystal',
                '9. matrix', '10. sphere', '11. dynamic', '12. living'
              ].map((w) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2638),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(w, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white)),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım, Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNetworkSwitcher() {
    final networks = [
      'BlockCore Testnet v1.0 (P2P)',
      'Ethereum Sepolia Testnet',
      'Polygon PoS Network',
      'Localhost Private Node (127.0.0.1:8545)',
    ];

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
            Text('Blokzincir Düğümü & Ağ Seçimi', style: RevolutTheme.titleMedium),
            const SizedBox(height: 16),
            ...networks.map((net) {
              final isSel = selectedNetwork == net;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.hub, color: isSel ? RevolutTheme.accentGreen : Colors.white54),
                title: Text(net, style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                trailing: isSel ? const Icon(Icons.check_circle, color: RevolutTheme.accentGreen, size: 20) : null,
                onTap: () {
                  setState(() => selectedNetwork = net);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ağ Değiştirildi: $net')),
                  );
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
    final walletState = WalletState.instance;

    return ListenableBuilder(
      listenable: walletState,
      builder: (context, _) {
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
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Text(
                      'MG',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              walletState.userName,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5A93C).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE5A93C)),
                              ),
                              child: Text(
                                walletState.membershipPlan,
                                style: const TextStyle(color: Color(0xFFE5A93C), fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          walletState.revtag,
                          style: const TextStyle(color: RevolutTheme.royalBlue, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified, color: RevolutTheme.accentGreen, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                walletState.kycTier,
                                style: RevolutTheme.caption.copyWith(color: RevolutTheme.accentGreen),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
              const SizedBox(height: 14),
              // Web3 Onboarding & Identity Wizard Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47E8), Color(0xFF1E3A8A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: RevolutTheme.royalBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  title: const Text(
                    'Web3 Onboarding & Kimlik Sihirbazı',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Revtag, zk-KYC ve hedefleri yeniden yapılandır',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 13),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingWizardPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Wallet Address Card with Copy Button
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.lock, color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BLOKZİNCİR ADRESİ', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text('0x71C98B2a4F9e8C12...4E390', style: RevolutTheme.monoNumeric.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cüzdan adresi panoya kopyalandı!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          // Network Switcher
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E2638),
              child: Icon(Icons.wifi, color: RevolutTheme.accentGreen, size: 20),
            ),
            title: Text('Aktif Ağ: $selectedNetwork', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Düğüm değiştirmek için dokunun (Gecikme 14ms)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: _showNetworkSwitcher,
          ),
          const Divider(height: 1, color: Colors.white12),
          // Seed phrase export
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E2638),
              child: Icon(Icons.key, color: Colors.amber, size: 20),
            ),
            title: const Text('12 Kelimelik Kurtarma Anahtarı', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Görüntülemek için dokunun (Yedeklendi ✓)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: _showSeedPhraseDialog,
          ),
          const Divider(height: 1, color: Colors.white12),
          // Network Activity Notifications
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E2638),
              child: Icon(AppIcons.bell, color: Colors.cyan, size: 20),
            ),
            title: const Text('Ağ Olayları & Bildirimler', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Doğrulayıcı ve işlem bildirim günlüğü', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => NotificationModal(onClearBadge: () {}),
              );
            },
          ),
          const Divider(height: 1, color: Colors.white12),
          // Proof of Reserves (PoR)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E2638),
              child: Icon(Icons.verified_user, color: RevolutTheme.accentGreen, size: 20),
            ),
            title: const Text('Proof of Reserves (PoR)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Merkle Tree ile %100 rezerv karşılığı denetimi', style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ProofOfReservesModal(),
              );
            },
          ),
          const Divider(height: 1, color: Colors.white12),
          // Biometric switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const CircleAvatar(
              backgroundColor: Color(0xFF1E2638),
              child: Icon(Icons.fingerprint, color: Colors.blueAccent, size: 20),
            ),
            title: const Text('Biyometrik Kimlik Doğrulama', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('İşlem onayında FaceID / Parmak İzi iste', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: biometricEnabled,
            activeColor: RevolutTheme.royalBlue,
            onChanged: (v) => setState(() => biometricEnabled = v),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
      },
    );
  }
}
