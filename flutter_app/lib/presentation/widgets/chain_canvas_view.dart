import 'dart:convert';

import 'package:crypto/crypto.dart';
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
        return SingleChildScrollView(
          child: Padding(
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
                const SizedBox(height: 24),
                _MerkleTreeSection(block: block),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();
  }
}

class _MerkleTreeSection extends StatelessWidget {
  const _MerkleTreeSection({required this.block});

  final Block block;

  @override
  Widget build(BuildContext context) {
    final transactions =
        block.transactions.isEmpty ? ['Tx1', 'Tx2', 'Tx3'] : block.transactions;
    final levels = _buildMerkleLevels(transactions);
    final root = block.merkleRoot.isEmpty ? levels.last.single : block.merkleRoot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merkle Kökü ve İşlem Ağacı',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 5),
        Text(
          'İşlemler ikişerli hashlenerek tek bir kökte birleşir.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        _MerkleNode(label: 'MERKLE ROOT', value: _shortHash(root), isRoot: true),
        for (var levelIndex = levels.length - 2;
            levelIndex >= 0;
            levelIndex--) ...[
          _MerkleConnector(
            parentCount: levels[levelIndex + 1].length,
            childCount: levels[levelIndex].length,
          ),
          _MerkleLevel(
            values: levels[levelIndex],
            labels: levelIndex == 0 ? transactions : null,
          ),
        ],
      ],
    );
  }
}

class _MerkleNode extends StatelessWidget {
  const _MerkleNode({
    required this.label,
    required this.value,
    this.isRoot = false,
  });

  final String label;
  final String value;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final color = isRoot
        ? const Color(0xFF53F2C2)
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      constraints: const BoxConstraints(minWidth: 112, maxWidth: 148),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isRoot ? const Color(0xFF17352F) : const Color(0xFF1A2226),
        border: Border.all(color: color.withOpacity(.45)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MerkleLevel extends StatelessWidget {
  const _MerkleLevel({required this.values, this.labels});

  final List<String> values;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < values.length; index++)
            Padding(
              padding: EdgeInsets.only(right: index == values.length - 1 ? 0 : 8),
              child: _MerkleNode(
                label: labels?[index] ?? 'HASH ${index + 1}',
                value: _shortHash(values[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _MerkleConnector extends StatelessWidget {
  const _MerkleConnector({
    required this.parentCount,
    required this.childCount,
  });

  final int parentCount;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    final width = (childCount * 156.0) - 8;
    return SizedBox(
      width: width < 112 ? 112 : width,
      height: 30,
      child: CustomPaint(
        painter: _MerkleConnectorPainter(
          parentCount: parentCount,
          childCount: childCount,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MerkleConnectorPainter extends CustomPainter {
  const _MerkleConnectorPainter({
    required this.parentCount,
    required this.childCount,
  });

  final int parentCount;
  final int childCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF53636B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final parentSpacing = size.width / parentCount;
    final childSpacing = size.width / childCount;
    final branchY = size.height / 2;

    for (var index = 0; index < childCount; index++) {
      final parentIndex = index ~/ 2;
      final parentX = (parentIndex + .5) * parentSpacing;
      final childX = (index + .5) * childSpacing;
      canvas.drawLine(Offset(parentX, 0), Offset(parentX, branchY), paint);
      canvas.drawLine(Offset(parentX, branchY), Offset(childX, branchY), paint);
      canvas.drawLine(
        Offset(childX, branchY),
        Offset(childX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MerkleConnectorPainter oldDelegate) =>
      oldDelegate.parentCount != parentCount ||
      oldDelegate.childCount != childCount;
}

List<List<String>> _buildMerkleLevels(List<String> transactions) {
  var level = transactions.map(_hashText).toList();
  final levels = <List<String>>[level];
  while (level.length > 1) {
    final next = <String>[];
    for (var index = 0; index < level.length; index += 2) {
      final right = index + 1 < level.length ? level[index + 1] : level[index];
      next.add(_hashText('${level[index]}$right'));
    }
    level = next;
    levels.add(level);
  }
  return levels;
}

String _hashText(String value) =>
    sha256.convert(utf8.encode(value)).toString();

String _shortHash(String value) =>
    value.length > 14 ? '${value.substring(0, 14)}…' : value;

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
