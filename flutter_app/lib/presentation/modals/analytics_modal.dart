import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class AnalyticsModal extends StatelessWidget {
  final int currentBlockHeight;

  const AnalyticsModal({super.key, required this.currentBlockHeight});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Network Telemetry & Analytics', style: RevolutTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard('AĞ PERFORMANSI', [
            _buildStatRow('Canlı Blok Yüksekliği:', '#$currentBlockHeight'),
            _buildStatRow('Ortalama Blok Üretim Süresi:', '2.1 saniye'),
            _buildStatRow('Aktif İşlem Hızı (TPS):', '28.4 tx/s'),
            _buildStatRow('Konsensüs Türü:', 'Proof-of-Stake (PoS)'),
          ]),
          const SizedBox(height: 14),
          _buildStatCard('GAZ & EKONOMİ', [
            _buildStatRow('Canlı Gas Ücreti:', '14 Gwei (Çok Hızlı)'),
            _buildStatRow('Kilitli Toplam Değer (TVL):', '\$1,420,850 USD'),
            _buildStatRow('Aktif Doğrulayıcı Düğümler:', 'Alpha, Beta, Gamma (3 Node)'),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(String header, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(color: RevolutTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: RevolutTheme.monoNumeric.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
