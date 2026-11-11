import 'package:flutter/material.dart';

import '../../domain/entities/block.dart';

class ChainCanvasView extends StatelessWidget {
  const ChainCanvasView({
    required this.blocks,
    required this.onCorruptBlock,
    super.key,
  });

  final List<Block> blocks;
  final void Function(int index, String maliciousData) onCorruptBlock;

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
              _BlockCard(
                block: block,
                isGenesis: index == 0,
                onCorrupt: (maliciousData) =>
                    onCorruptBlock(block.index, maliciousData),
              ),
              if (index < blocks.length - 1)
                _ChainLink(
                  hash: blocks[index + 1].previousHash,
                  isValid: block.isValid && blocks[index + 1].isValid,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.block,
    required this.isGenesis,
    required this.onCorrupt,
  });

  final Block block;
  final bool isGenesis;
  final ValueChanged<String> onCorrupt;

  @override
  Widget build(BuildContext context) {
    const healthyAccent = Color(0xFF53F2C2);
    const invalidAccent = Color(0xFFE53935);
    final accent = block.isValid ? healthyAccent : invalidAccent;
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showAuditSheet(context),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: block.isValid
              ? colors.surfaceContainerHigh
              : const Color(0xFF4A1515),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(.55)),
          boxShadow: [
            if (block.isValid)
              BoxShadow(
                color: accent.withOpacity(.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
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
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                Icon(
                  block.isValid
                      ? (isGenesis ? Icons.radar : Icons.link)
                      : Icons.warning_amber_rounded,
                  size: 18,
                  color: accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              block.isValid
                  ? (block.isCorrupted ? 'TAMPER FLAGGED' : 'VALID BLOCK')
                  : 'CHAIN INVALID',
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            _DataRow(label: 'HASH', value: block.shortHash),
            const SizedBox(height: 10),
            _DataRow(label: 'PREV', value: block.shortPreviousHash),
            const SizedBox(height: 10),
            _DataRow(
              label: 'DATA',
              value: block.data.isEmpty ? 'No payload' : block.data,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _DataRow(label: 'NONCE', value: '${block.nonce}')),
                _DifficultyBadge(value: block.difficulty, color: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAuditSheet(BuildContext context) async {
    final controller = TextEditingController(
      text: block.data.isEmpty ? 'malicious payload' : block.data,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12191D),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blok Denetim & Saldırı',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Block #${block.index} / ${block.isValid ? 'geçerli' : 'geçersiz'}',
                style: TextStyle(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Blok verisi',
                  hintText: 'Yeni veri girin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final data = controller.text.trim();
                    if (data.isEmpty) return;
                    Navigator.of(sheetContext).pop();
                    onCorrupt(data);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.gpp_bad_outlined),
                  label: const Text('Veriyi Manipüle Et (Saldır)'),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
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
  const _DifficultyBadge({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          'D$value',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ChainLink extends StatelessWidget {
  const _ChainLink({required this.hash, required this.isValid});

  final String hash;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(82, 16),
            painter: _ChainLinkPainter(isValid: isValid),
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
            style: TextStyle(
              color: isValid
                  ? const Color(0xFF53F2C2)
                  : const Color(0xFFE53935),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ChainLinkPainter extends CustomPainter {
  const _ChainLinkPainter({required this.isValid});

  final bool isValid;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height / 2);
    if (isValid) {
      path.cubicTo(
        size.width * .28,
        0,
        size.width * .72,
        size.height,
        size.width,
        size.height / 2,
      );
    } else {
      path.lineTo(size.width * .42, size.height / 2);
      path.moveTo(size.width * .58, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = (isValid ? const Color(0xFF53F2C2) : const Color(0xFFE53935))
            .withOpacity(.16)
        ..strokeWidth = isValid ? 7 : 4
        ..style = PaintingStyle.stroke
        ..maskFilter = isValid
            ? const MaskFilter.blur(BlurStyle.normal, 4)
            : null,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = isValid ? const Color(0xFF53F2C2) : const Color(0xFFE53935)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChainLinkPainter oldDelegate) =>
      oldDelegate.isValid != isValid;
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
