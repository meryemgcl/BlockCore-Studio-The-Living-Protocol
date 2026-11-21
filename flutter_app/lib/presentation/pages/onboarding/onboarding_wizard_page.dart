import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/state/wallet_state.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingWizardPage extends StatefulWidget {
  const OnboardingWizardPage({super.key});

  @override
  State<OnboardingWizardPage> createState() => _OnboardingWizardPageState();
}

class _OnboardingWizardPageState extends State<OnboardingWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form State
  late TextEditingController _revtagController;
  bool _isRevtagChecking = false;
  bool _isRevtagAvailable = true;

  final Set<String> _selectedPurposes = {
    'Transfers (P2P)',
    'Smart Metal Card',
    'PoS Staking (%5.4 APY)',
    'Crypto Portfolio',
    'Multi-Currency FX',
  };

  int _selectedKycOption = 0; // 0: zk-ID, 1: Documents
  bool _isGeneratingZkProof = false;
  bool _zkProofDone = false;

  int _selectedPlanIndex = 1; // 0: Standard, 1: Ultra Sovereign

  @override
  void initState() {
    super.initState();
    final initialTag = WalletState.instance.revtag.replaceAll('@', '');
    _revtagController = TextEditingController(text: initialTag);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _revtagController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWizard();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _finishWizard() {
    final state = WalletState.instance;
    state.updateRevtag(_revtagController.text.trim());
    state.updatePurposes(_selectedPurposes.toList());
    state.updateKycStatus(_zkProofDone || _selectedKycOption == 0
        ? 'Tier 2 Identity Verified (zk-SNARK Proof)'
        : 'Tier 2 Document Verified');
    state.updateMembershipPlan(_selectedPlanIndex == 1 ? 'ULTRA SOVEREIGN' : 'STANDARD');

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF131927),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: RevolutTheme.accentGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Web3 Kimlik ve Tercihleriniz Kaydedildi: ${state.revtag} (${state.membershipPlan})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RevolutTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildStep1Welcome(),
                  _buildStep2Purposes(),
                  _buildStep3Revtag(),
                  _buildStep4ZkKyc(),
                  _buildStep5Plans(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Step progress indicator bar (matches Revolut stories header)
          Row(
            children: List.generate(_totalSteps, (i) {
              final isFilled = i <= _currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isFilled ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(AppIcons.back, color: Colors.white),
                onPressed: _previousPage,
              ),
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: RevolutTheme.caption.copyWith(color: Colors.white70),
              ),
              TextButton(
                onPressed: _finishWizard,
                child: const Text('Skip', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 1: Hero Welcome (Revolut 02.png / 04.png)
  Widget _buildStep1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RevolutTheme.royalBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RevolutTheme.royalBlue.withOpacity(0.4)),
            ),
            child: const Text(
              'WEB3 SOVEREIGN NEOBANK',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'READY TO OWN\nYOUR MONEY\nON-CHAIN?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Geleneksel bankacılık limitlerini aşın. Sıfır Gas Paymaster ve zk-Proof egemen kimlikle tüm varlıklarınızı tek merkezden yönetin.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const Spacer(),
          // 3D Medallion simulation
          Center(
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF2C5AFF), Color(0xFF0F172A), Colors.black],
                  stops: [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: RevolutTheme.royalBlue.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.white30, width: 2),
              ),
              child: const Center(
                child: Text(
                  '₿',
                  style: TextStyle(fontSize: 72, color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _nextPage,
              child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 2: Purposes & Objectives (Revolut 19.png / 20.png)
  Widget _buildStep2Purposes() {
    final everydayList = [
      'Transfers (P2P)',
      'Smart Metal Card',
      'Split Bill Calculator',
      'Multi-Currency FX',
      'Budgeting & Limits',
      'Instant Notifications',
    ];

    final defiList = [
      'PoS Staking (%5.4 APY)',
      'Crypto Portfolio',
      'Tokenized RWA (Gold & S&P)',
      'zk-Identity Privacy',
      'Decentralized Revtag',
      'Multi-Node Telemetry',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        const Text(
          'What do you want to use BlockCore for?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'We customize your on-chain dashboard and recommended smart modules based on your selections.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Text(
          'Everyday needs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: everydayList.map((p) => _buildPurposePill(p)).toList(),
        ),
        const SizedBox(height: 28),
        const Text(
          'Web3 & Global Spending',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: defiList.map((p) => _buildPurposePill(p)).toList(),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            onPressed: _nextPage,
            child: Text(
              'Continue (${_selectedPurposes.length} selected)',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPurposePill(String title) {
    final isSelected = _selectedPurposes.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPurposes.remove(title);
          } else {
            _selectedPurposes.add(title);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // STEP 3: Decentralized Revtag (Revolut 21.png / 22.png)
  Widget _buildStep3Revtag() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your profile',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Text('MG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 12, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your Revtag to get easily paid by your friends without exposing long 0x addresses.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 28),
          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRevtagAvailable ? RevolutTheme.accentGreen.withOpacity(0.5) : Colors.white12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Revtag (ENS Handle)', style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('@', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _revtagController,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'yourname',
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _isRevtagChecking = true;
                          });
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isRevtagChecking = false;
                                _isRevtagAvailable = val.trim().isNotEmpty && val.trim().length >= 3;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    if (_isRevtagChecking)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    else if (_isRevtagAvailable)
                      const Icon(Icons.check_circle, color: RevolutTheme.accentGreen, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isRevtagAvailable
                    ? '✓ Revtag available on BlockCore Registry'
                    : 'En az 3 karakter giriniz',
                style: TextStyle(
                  color: _isRevtagAvailable ? RevolutTheme.accentGreen : Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_revtagController.text.length}/32',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _isRevtagAvailable ? _nextPage : null,
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // STEP 4: zk-KYC & Sovereign Verification (Revolut 18.png)
  Widget _buildStep4ZkKyc() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify your identity',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your verification pathway. Web3 Sovereign ID preserves 100% on-chain anonymity.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Option 1: zk-Proof
          _buildKycCard(
            index: 0,
            title: 'Verify using zk-ID (Sovereign)',
            badge: '⚡ Instant (zk-SNARK)',
            desc: 'Kriptografik sıfır bilgi ispatı oluşturun. Kimlik veriniz asla sunucuya gitmez.',
            icon: Icons.shield,
          ),
          const SizedBox(height: 16),
          // Option 2: Document KYC
          _buildKycCard(
            index: 1,
            title: 'Verify using documents (ID / NRIC)',
            badge: 'Tier 2 Visa',
            desc: 'Pasaport ve resmi kimlik yükleyerek Visa Metal Kart ve SWIFT limitlerini açın.',
            icon: Icons.badge,
          ),
          const Spacer(),
          if (_isGeneratingZkProof) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2638),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'zk-SNARK Kanıtı Hesaplanıyor (SHA-256 Quorum)...',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _isGeneratingZkProof
                  ? null
                  : () async {
                      if (_selectedKycOption == 0 && !_zkProofDone) {
                        setState(() => _isGeneratingZkProof = true);
                        await Future.delayed(const Duration(milliseconds: 1200));
                        if (!mounted) return;
                        setState(() {
                          _isGeneratingZkProof = false;
                          _zkProofDone = true;
                        });
                      }
                      _nextPage();
                    },
              child: Text(
                _zkProofDone ? 'Verified ✓ Continue' : 'Generate zk-Proof & Continue',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildKycCard({
    required int index,
    required String title,
    required String badge,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = _selectedKycOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedKycOption = index),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2234),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? RevolutTheme.royalBlue : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? RevolutTheme.royalBlue.withOpacity(0.2) : Colors.white10,
              child: Icon(icon, color: isSelected ? RevolutTheme.royalBlue : Colors.white70, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: RevolutTheme.accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: RevolutTheme.accentGreen, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 5: Plans & Tiers (Revolut 24.png)
  Widget _buildStep5Plans() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your Web3 plan',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sovereign validator perks, 0% Gas Paymaster and luxury metal cards.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          // Plan Selector Chips
          Row(
            children: [
              _buildPlanChip('Standard (0 BLC)', 0),
              const SizedBox(width: 10),
              _buildPlanChip('Ultra Sovereign', 1),
            ],
          ),
          const SizedBox(height: 20),
          // Preview Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: _selectedPlanIndex == 1
                    ? const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF0D1424), Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF2C394E), Color(0xFF131927)],
                      ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _selectedPlanIndex == 1 ? const Color(0xFFE5A93C) : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedPlanIndex == 1 ? 'ULTRA SOVEREIGN' : 'STANDARD',
                        style: TextStyle(
                          color: _selectedPlanIndex == 1 ? const Color(0xFFE5A93C) : Colors.white70,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _selectedPlanIndex == 1 ? '1 Month Free' : 'Free Forever',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedPlanIndex == 1 ? '10 BLC / month after trial' : '0 BLC / month',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const Divider(height: 28, color: Colors.white12),
                  ...(_selectedPlanIndex == 1
                      ? [
                          _buildPerkRow(Icons.bolt, '0% Gas Paymaster (Gasless Transactions)'),
                          _buildPerkRow(Icons.credit_card, 'Free Laser-etched Metal Smart Card'),
                          _buildPerkRow(Icons.savings, '%1.5 Staking Cashback on All Spends'),
                          _buildPerkRow(Icons.speed, 'High-Priority Mempool Block Inclusion'),
                        ]
                      : [
                          _buildPerkRow(Icons.check, 'Standard Mempool Gas Rates'),
                          _buildPerkRow(Icons.credit_card, 'Digital Smart Card (Apple/Google Pay)'),
                          _buildPerkRow(Icons.savings, 'Standard Staking Yield (%4.2 APY)'),
                        ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _finishWizard,
              child: const Text('Complete Web3 Onboarding', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPlanChip(String label, int index) {
    final isSel = _selectedPlanIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.black : Colors.white70,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPerkRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: RevolutTheme.accentGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
