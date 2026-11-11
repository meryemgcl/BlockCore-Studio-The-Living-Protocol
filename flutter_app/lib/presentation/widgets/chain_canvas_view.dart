import 'package:flutter/material.dart';

import '../../domain/entities/block.dart';

class ChainCanvasView extends StatelessWidget {
  const ChainCanvasView({required this.blocks, super.key});

  final List<Block> blocks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const _EmptyChain();
    }

    return SizedBox(
      height: 270,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        scrollDirection: Axis.horizontal,
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          final block = blocks[index];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BlockCard(block: block, isGenesis: index == 0),
              if (index < blocks.length - 1)
                _ChainLink(hash: blocks[index + 1].previousHash),
            ],
          );
        },
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block, required this.isGenesis});

  final Block block;
  final bool isGenesis;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF53F2C2);
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BLOCK ${block.index.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              Icon(
                isGenesis ? Icons.radar : Icons.link,
                size: 18,
                color: accent,
              ),
            ],
          ),
          const Spacer(),
          _DataRow(label: 'HASH', value: block.shortHash),
          const SizedBox(height: 10),
          _DataRow(label: 'PREV', value: block.shortPreviousHash),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DataRow(label: 'NONCE', value: '${block.nonce}')),
              _DifficultyBadge(value: block.difficulty),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF53F2C2).withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          'D$value',
          style: const TextStyle(
            color: Color(0xFF53F2C2),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ChainLink extends StatelessWidget {
  const _ChainLink({required this.hash});

  final String hash;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(82, 16),
            painter: _NeonLinkPainter(),
          ),
          const SizedBox(height: 7),
          Text(
            'prevHash',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            hash.length > 8 ? '${hash.substring(0, 8)}…' : hash,
            style: const TextStyle(
              color: Color(0xFF53F2C2),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonLinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..cubicTo(size.width * .28, 0, size.width * .72, size.height, size.width, size.height / 2);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF53F2C2).withOpacity(.18)
        ..strokeWidth = 9
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF53F2C2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyChain extends StatelessWidget {
  const _EmptyChain();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        'Zincir boş.\nİlk bloğu kazmak için başlat düğmesine dokun.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}
