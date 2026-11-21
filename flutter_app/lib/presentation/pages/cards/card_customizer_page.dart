import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CardCustomizerPage extends StatefulWidget {
  const CardCustomizerPage({super.key});

  @override
  State<CardCustomizerPage> createState() => _CardCustomizerPageState();
}

class _CardCustomizerPageState extends State<CardCustomizerPage> {
  int selectedColorIndex = 0;

  final List<Map<String, dynamic>> cardThemes = [
    {
      'name': 'Premium · Space Grey',
      'desc': 'Made from aerospace-grade finish with a striking shimmer effect, our beautiful Premium card feels as good as it looks.',
      'gradient': [Color(0xFF4A5568), Color(0xFF2D3748), Color(0xFF1A202C)],
      'color': Color(0xFF4A5568),
      'textColor': Colors.white,
    },
    {
      'name': 'Special · Rose Gold',
      'desc': 'Soft metallic rose shimmer designed with bespoke laser-etched cryptography accents.',
      'gradient': [Color(0xFFE8B4B8), Color(0xFFD49B9F), Color(0xFFA26769)],
      'color': Color(0xFFE8B4B8),
      'textColor': Color(0xFF2D1B1E),
    },
    {
      'name': 'Web3 · Ethereum Lavender',
      'desc': 'Cold-storage enabled smart NFC chip with dual EVM private-key hardware isolation.',
      'gradient': [Color(0xFF9FA8DA), Color(0xFF7986CB), Color(0xFF3949AB)],
      'color': Color(0xFF9FA8DA),
      'textColor': Colors.white,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentTheme = cardThemes[selectedColorIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blue Radial Glow at Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.6),
                  radius: 0.9,
                  colors: [
                    Color(0xFF0F36D4),
                    Color(0xFF071B6A),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header with Customisable Pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✨ ', style: TextStyle(fontSize: 12)),
                            Text(
                              'Customisable',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Vertical Card Preview (Exact proportions from Screenshot 2)
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 230,
                    height: 360,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: currentTheme['gradient'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (currentTheme['color'] as Color).withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // EMV Chip Icon
                            Container(
                              width: 38,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            // Rotated Brand Name
                            RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                'Revolut',
                                style: TextStyle(
                                  color: currentTheme['textColor'] as Color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Rotated Cardholder Name & Web3 Address
                        RotatedBox(
                          quarterTurns: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MERYEM GÜÇLÜ',
                                style: TextStyle(
                                  color: currentTheme['textColor'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '0x71C...390 (Cold Key)',
                                style: TextStyle(
                                  color: (currentTheme['textColor'] as Color).withOpacity(0.65),
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Visa Logo
                        Text(
                          'VISA',
                          style: TextStyle(
                            color: currentTheme['textColor'] as Color,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Card Details Title & Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        currentTheme['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentTheme['desc'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Color Swatches Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(cardThemes.length, (index) {
                    final isSelected = selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColorIndex = index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardThemes[index]['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                // Bottom Sticky Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${currentTheme['name']} Sanal Kartı Başarıyla Tanımlandı!',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Get card for free',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
