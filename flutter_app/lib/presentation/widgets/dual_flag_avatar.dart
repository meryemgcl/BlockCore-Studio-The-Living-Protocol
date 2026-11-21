import 'package:flutter/material.dart';

class DualFlagAvatar extends StatelessWidget {
  final String fromFlag;
  final String toFlag;

  const DualFlagAvatar({
    super.key,
    required this.fromFlag,
    required this.toFlag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: _buildFlagCircle(fromFlag),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: _buildFlagCircle(toFlag),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCircle(String flag) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF131927), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        flag,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
