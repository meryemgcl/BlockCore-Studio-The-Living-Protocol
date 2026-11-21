import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedBalanceText extends StatelessWidget {
  final double value;
  final String symbol;

  const AnimatedBalanceText({
    super.key,
    required this.value,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animatedVal, _) {
        final parts = animatedVal.toStringAsFixed(2).split('.');
        final integerPart = parts[0];
        final cents = parts[1];

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$symbol$integerPart', style: RevolutTheme.heroBalance),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '.$cents',
                style: RevolutTheme.heroBalance.copyWith(fontSize: 24),
              ),
            ),
          ],
        );
      },
    );
  }
}
