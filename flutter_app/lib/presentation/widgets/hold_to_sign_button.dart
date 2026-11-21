import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

enum SignState { idle, mempool, confirmed }

class HoldToSignButton extends StatefulWidget {
  final Future<void> Function() onSignComplete;
  final String label;

  const HoldToSignButton({
    super.key,
    required this.onSignComplete,
    this.label = 'Basılı Tut ve İmzala (Hold to Sign)',
  });

  @override
  State<HoldToSignButton> createState() => _HoldToSignButtonState();
}

class _HoldToSignButtonState extends State<HoldToSignButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  SignState _signState = SignState.idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerSigning();
      }
    });
  }

  void _triggerSigning() async {
    setState(() => _signState = SignState.mempool);

    // 1.5 seconds in Mempool (Pending 0/3)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    await widget.onSignComplete();
    setState(() => _signState = SignState.confirmed);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _signState = SignState.idle;
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signState == SignState.mempool) {
      return Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2E220C),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.amber),
            ),
            SizedBox(width: 12),
            Text(
              'AĞA YAYINLANIYOR (Mempool 0/3 Onay)...',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_signState == SignState.confirmed) {
      return Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F2620),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: RevolutTheme.accentGreen),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: RevolutTheme.accentGreen, size: 20),
            SizedBox(width: 10),
            Text(
              'BLOKTA DOĞRULANDI (CONFIRMED ✓)',
              style: TextStyle(color: RevolutTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (_controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          return Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: RevolutTheme.royalBlue,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                if (progress > 0.05)
                  BoxShadow(
                    color: RevolutTheme.royalBlue.withOpacity(0.5 * progress),
                    blurRadius: 18 * progress,
                    spreadRadius: 2 * progress,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Progress Fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        progress > 0.5 ? Icons.lock_open : Icons.touch_app,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        progress > 0.1
                            ? 'İmzalanıyor... %${(progress * 100).toInt()}'
                            : widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
