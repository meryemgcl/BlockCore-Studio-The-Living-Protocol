import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class NotificationModal extends StatelessWidget {
  final VoidCallback onClearBadge;

  const NotificationModal({super.key, required this.onClearBadge});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Yeni Blok Doğrulandı #14892',
        'desc': 'Alpha Node konsensüs quorum tarafından zincire eklendi.',
        'time': '2 dk önce',
        'icon': Icons.hub,
        'color': RevolutTheme.accentGreen,
      },
      {
        'title': 'P2P Transfer Onaylandı',
        'desc': 'Alice cüzdanından gelen transfer HMAC-SHA256 ile doğrulandı.',
        'time': '14 dk önce',
        'icon': AppIcons.send,
        'color': RevolutTheme.royalBlue,
      },
      {
        'title': 'Gas Fiyat Uyarısı',
        'desc': 'Ağdaki transfer maliyeti 12 Gwei seviyesine geriledi.',
        'time': '1 saat önce',
        'icon': Icons.bolt,
        'color': Colors.amber,
      },
      {
        'title': 'Biyometrik Oturum Doğrulandı',
        'desc': 'Web3 Sovereign Account yeni donanım anahtarıyla senkronize.',
        'time': '3 saat önce',
        'icon': Icons.verified_user,
        'color': Colors.cyan,
      },
    ];

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
              Text('Ağ Olayları & Bildirimler', style: RevolutTheme.titleMedium),
              TextButton(
                onPressed: () {
                  onClearBadge();
                  Navigator.pop(context);
                },
                child: const Text('Okundu Say', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...notifications.map((n) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              leading: CircleAvatar(
                backgroundColor: (n['color'] as Color).withOpacity(0.15),
                child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
              ),
              title: Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(n['desc'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: Text(n['time'] as String, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
