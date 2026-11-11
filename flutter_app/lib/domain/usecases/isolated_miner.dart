import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';

import '../entities/block.dart';

class MiningParams {
  const MiningParams({
    required this.index,
    required this.previousHash,
    required this.difficulty,
    required this.data,
    required this.merkleRoot,
    this.validator = '',
  });

  final int index;
  final String previousHash;
  final int difficulty;
  final String data;
  final String merkleRoot;
  final String validator;
}

class MiningOutput {
  const MiningOutput({
    required this.block,
    required this.hashesChecked,
    required this.duration,
  });

  final Block block;
  final int hashesChecked;
  final Duration duration;
}

class IsolatedMiner {
  /// Madenciliği tamamen izole edilmiş bir arka plan iş parçacığında (Isolate)
  /// çalıştırır. UI thread'i asla bloklanmaz (120 FPS akıcılık garantisi).
  static Future<MiningOutput> mine(MiningParams params) async {
    return Isolate.run(() => _executeMining(params));
  }

  static MiningOutput _executeMining(MiningParams params) {
    final stopwatch = Stopwatch()..start();
    final target = '0' * params.difficulty;
    var nonce = 0;
    var hashesChecked = 0;
    var hash = '';

    do {
      final payload =
          '${params.index}:${params.previousHash}:$nonce:${params.difficulty}:${params.data}:${params.merkleRoot}:${params.validator}';
      hash = sha256.convert(utf8.encode(payload)).toString();
      hashesChecked++;
      nonce++;
    } while (!hash.startsWith(target));

    stopwatch.stop();

    final block = Block(
      index: params.index,
      hash: hash,
      previousHash: params.previousHash,
      nonce: nonce - 1,
      difficulty: params.difficulty,
      data: params.data,
      merkleRoot: params.merkleRoot,
      validator: params.validator,
      isValid: true,
      isCorrupted: false,
    );

    return MiningOutput(
      block: block,
      hashesChecked: hashesChecked,
      duration: stopwatch.elapsed,
    );
  }
}
