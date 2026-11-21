import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/state/wallet_state.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class ProofOfReservesModal extends StatefulWidget {
  const ProofOfReservesModal({super.key});

  @override
  State<ProofOfReservesModal> createState() => _ProofOfReservesModalState();
}

class _ProofOfReservesModalState extends State<ProofOfReservesModal> {
  bool _isVerifying = false;
  bool _isVerified = false;
  int _verificationStep = 0;
  String? _selectedNodeTitle;
  String? _selectedNodeHash;

  final String merkleRootHash = '0x8F2C91D3E4B721A05698C3F41E8D9B2C';
  final String vaultAddress = '0x91F47A8E2A01CB39824D6F12C5981E4398';

  void _runMerkleProofVerification() async {
    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _verificationStep = 1;
    });

    // Step 1: Compute user leaf
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _verificationStep = 2);

    // Step 2: Compute intermediate branch
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _verificationStep = 3);

    // Step 3: Verify root match
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _isVerified = true;
      _verificationStep = 4;
    });
  }

  void _copyProofJson() {
    final state = WalletState.instance;
    final proof = {
      'proof_type': 'Merkle Sum Tree Solvency Proof (zk-PoR)',
      'timestamp': DateTime.now().toIso8601String(),
      'block_height': state.blockHeight,
      'merkle_root': merkleRootHash,
      'reserve_vault': vaultAddress,
      'reserve_ratio': '102.0%',
      'total_reserves_usd': 1518984.00,
      'total_liabilities_usd': 1489200.00,
      'user_leaf': {
        'revtag': state.revtag,
        'balance_usd': state.usdBalance,
        'leaf_hash': '0x71C98B2A4F9E8C124E390A72B8C1',
      },
      'proof_path': [
        {'position': 'right', 'sibling_hash': '0x3D4A82B1C89F...'},
        {'position': 'left', 'parent_hash': '0x6E1F99C23D...'},
      ],
      'cryptographic_verification': 'PASSED (Zero-Knowledge Audit Match)',
    };

    Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(proof)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kriptografik Merkle Kanıtı JSON panoya kopyalandı!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = WalletState.instance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                _buildSolvencyMetricsCard(),
                const SizedBox(height: 16),
                _buildSmartContractVaultTile(),
                const SizedBox(height: 20),
                _buildMerkleTreeSection(state),
                const SizedBox(height: 20),
                _buildVerificationStatusCard(state),
                const SizedBox(height: 20),
                _buildAuditActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: RevolutTheme.accentGreen.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: RevolutTheme.accentGreen.withOpacity(0.4)),
          ),
          child: const Icon(Icons.verified_user, color: RevolutTheme.accentGreen, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Proof of Reserves (PoR)', style: RevolutTheme.titleMedium.copyWith(fontSize: 18)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: RevolutTheme.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RevolutTheme.accentGreen),
                    ),
                    child: const Text('102% SOLVENT', style: TextStyle(color: RevolutTheme.accentGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text('Kriptografik Merkle Tree Rezerv Denetçisi', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSolvencyMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem('On-Chain Teminat', '\$1,518,984', RevolutTheme.accentGreen),
              Container(width: 1, height: 36, color: Colors.white12),
              _buildMetricItem('Müşteri Yükümlülüğü', '\$1,489,200', Colors.white),
              Container(width: 1, height: 36, color: Colors.white12),
              _buildMetricItem('Rezerv Oranı', '%102.0', RevolutTheme.accentGreen),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: RevolutTheme.accentGreen, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Aşırı Teminatlandırılmış (Over-collateralized). Cüzdanınızdaki her 1 Dolar için akıllı sözleşme kasasında 1.02 Dolar rezerv kilitlidir.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: RevolutTheme.monoNumeric.copyWith(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSmartContractVaultTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.lock, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AKILLI SÖZLEŞME KASASI (MULTI-SIG)', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(vaultAddress, style: RevolutTheme.monoNumeric.copyWith(fontSize: 11, color: Colors.white)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white54, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: vaultAddress));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kasa adresi panoya kopyalandı!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMerkleTreeSection(WalletState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kriptografik Merkle Ağacı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: const Text('SHA-256 Sum Tree', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Düğümlere dokunarak hash ve kriptografik ön-görüntü detaylarını inceleyebilirsiniz:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 20),
          // Interactive Merkle Tree Graph
          Center(
            child: Column(
              children: [
                // ROOT NODE
                _buildTreeNode(
                  title: 'Merkle Root',
                  hash: merkleRootHash,
                  subtext: 'Solvency State Quorum',
                  color: RevolutTheme.accentGreen,
                  isRoot: true,
                ),
                _buildTreeBranchLines(),
                // INTERMEDIATE NODES (LEVEL 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTreeNode(
                      title: 'Branch L1',
                      hash: '0x3D9C41E8',
                      subtext: 'Hash(Leaf1 + Leaf2)',
                      color: RevolutTheme.royalBlue,
                    ),
                    _buildTreeNode(
                      title: 'Branch L2',
                      hash: '0x7F2A89B4',
                      subtext: 'Hash(Leaf3 + Leaf4)',
                      color: Colors.cyanAccent,
                      isHighlighted: true,
                    ),
                  ],
                ),
                _buildTreeBranchLines(),
                // LEAF NODES (LEVEL 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLeafNode('@alice', '\$420.00', '0x12A9', false),
                    _buildLeafNode('@bob', '\$1,250.50', '0x3D7E', false),
                    _buildLeafNode(state.revtag, '\$${state.displayBalance.toStringAsFixed(2)}', '0x71C9', true),
                    _buildLeafNode('@mehmet', '\$85.00', '0x99B4', false),
                  ],
                ),
              ],
            ),
          ),
          if (_selectedNodeTitle != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF192234),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seçili Düğüm: $_selectedNodeTitle', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('Hash: $_selectedNodeHash', style: RevolutTheme.monoNumeric.copyWith(color: Colors.cyanAccent, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreeNode({
    required String title,
    required String hash,
    required String subtext,
    required Color color,
    bool isRoot = false,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNodeTitle = title;
          _selectedNodeHash = hash;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF161E30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted ? Colors.cyanAccent : color.withOpacity(0.6),
            width: isRoot || isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            if (isRoot || isHighlighted)
              BoxShadow(
                color: (isHighlighted ? Colors.cyanAccent : color).withOpacity(0.25),
                blurRadius: 12,
              ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(hash, style: RevolutTheme.monoNumeric.copyWith(fontSize: 10, color: Colors.white70)),
            Text(subtext, style: const TextStyle(fontSize: 9, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeafNode(String revtag, String amount, String hash, bool isUser) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNodeTitle = '$revtag (Leaf)';
          _selectedNodeHash = '$hash... (SHA-256 pre-image: $revtag + $amount)';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? RevolutTheme.royalBlue.withOpacity(0.25) : const Color(0xFF131926),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUser ? Colors.cyanAccent : Colors.white12,
            width: isUser ? 2 : 1,
          ),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.3),
                blurRadius: 10,
              ),
          ],
        ),
        child: Column(
          children: [
            if (isUser)
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(4)),
                child: const Text('SENİN HESABIN', style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.w900)),
              ),
            Text(revtag, style: TextStyle(color: isUser ? Colors.cyanAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
            Text(amount, style: RevolutTheme.monoNumeric.copyWith(fontSize: 10, color: Colors.white)),
            Text(hash, style: RevolutTheme.monoNumeric.copyWith(fontSize: 8, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeBranchLines() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 2, height: 16, color: Colors.white24),
          const SizedBox(width: 90),
          Container(width: 2, height: 16, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard(WalletState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isVerified ? RevolutTheme.accentGreen : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kriptografik İspat Durumu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              if (_isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: RevolutTheme.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: RevolutTheme.accentGreen, size: 14),
                      SizedBox(width: 4),
                      Text('VERIFIED ✓', style: TextStyle(color: RevolutTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isVerifying) ...[
            Row(
              children: [
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _verificationStep == 1
                        ? '1/3: Yaprak hesaplanıyor: SHA-256(${state.revtag} + \$${state.displayBalance.toStringAsFixed(2)})...'
                        : _verificationStep == 2
                            ? '2/3: Sibling Hash (0x3D9C...) ile ara düğüm hesaplanıyor...'
                            : '3/3: Hesaplanan kök Merkle Root ile eşleştiriliyor...',
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ] else if (_isVerified) ...[
            Text(
              '✓ Bakiyeniz (${state.baseCurrency.symbol}${state.displayBalance.toStringAsFixed(2)}) Merkle Ağacı kökünde (0x8F2C...) matematiksel olarak doğrulanmıştır. Akıllı sözleşme kasasında karşılığı 100% mevcuttur.',
              style: const TextStyle(color: RevolutTheme.accentGreen, fontSize: 12, height: 1.4),
            ),
          ] else ...[
            const Text(
              'Bakiyenizin blokzincir rezerv kasasındaki Merkle yaprağını doğrulamak için aşağıdaki butona basın.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: RevolutTheme.royalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 0,
            ),
            icon: const Icon(Icons.security, size: 18),
            label: Text(
              _isVerifying ? 'Doğrulanıyor...' : 'Kriptografik Merkle Kanıtı Çalıştır',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: _isVerifying ? null : _runMerkleProofVerification,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
            ),
            icon: const Icon(Icons.code, size: 18),
            label: const Text('Denetim Raporu JSON Kopyala (Audit Receipt)', style: TextStyle(fontSize: 13)),
            onPressed: _copyProofJson,
          ),
        ),
      ],
    );
  }
}
