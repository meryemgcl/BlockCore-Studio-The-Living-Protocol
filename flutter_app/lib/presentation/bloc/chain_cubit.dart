import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/block.dart';

class ChainState {
  const ChainState({
    this.blocks = const [],
    this.isMining = false,
    this.miningNonce = 0,
    this.miningHash = '',
    this.hashesChecked = 0,
    this.lastDuration = Duration.zero,
  });

  final List<Block> blocks;
  final bool isMining;
  final int miningNonce;
  final String miningHash;
  final int hashesChecked;
  final Duration lastDuration;

  ChainState copyWith({
    List<Block>? blocks,
    bool? isMining,
    int? miningNonce,
    String? miningHash,
    int? hashesChecked,
    Duration? lastDuration,
  }) {
    return ChainState(
      blocks: blocks ?? this.blocks,
      isMining: isMining ?? this.isMining,
      miningNonce: miningNonce ?? this.miningNonce,
      miningHash: miningHash ?? this.miningHash,
      hashesChecked: hashesChecked ?? this.hashesChecked,
      lastDuration: lastDuration ?? this.lastDuration,
    );
  }
}

class ChainCubit extends Cubit<ChainState> {
  ChainCubit() : super(const ChainState());

  Future<void> addDemoBlock({int difficulty = 2}) async {
    if (state.isMining) return;

    final previous = state.blocks.isEmpty ? '0' * 64 : state.blocks.last.hash;
    final index = state.blocks.length;
    final startedAt = DateTime.now();

    emit(
      state.copyWith(
        isMining: true,
        miningNonce: 0,
        miningHash: '',
        hashesChecked: 0,
        lastDuration: Duration.zero,
      ),
    );

    final result = await _mineBlock(
      index: index,
      previousHash: previous,
      difficulty: difficulty,
      data: 'BlockCore transaction #$index',
    );
    emit(
      state.copyWith(
        blocks: [...state.blocks, result.block],
        isMining: false,
        miningNonce: result.block.nonce,
        miningHash: result.block.hash,
        hashesChecked: result.hashesChecked,
        lastDuration: DateTime.now().difference(startedAt),
      ),
    );
  }

  void validateChain() {
    var chainIsValid = true;
    final validatedBlocks = <Block>[];

    for (var index = 0; index < state.blocks.length; index++) {
      final block = state.blocks[index];
      final expectedPreviousHash =
          index == 0 ? '0' * 64 : state.blocks[index - 1].hash;
      final hashMatches = _hashBlock(
            block.index,
            block.previousHash,
            block.nonce,
            block.difficulty,
            block.data,
          ) ==
          block.hash;
      final previousMatches = block.previousHash == expectedPreviousHash;
      final isValid = chainIsValid && hashMatches && previousMatches;
      chainIsValid = isValid;
      validatedBlocks.add(
        Block(
          index: block.index,
          hash: block.hash,
          previousHash: block.previousHash,
          nonce: block.nonce,
          difficulty: block.difficulty,
          data: block.data,
          isValid: isValid,
          isCorrupted: block.isCorrupted || !hashMatches,
        ),
      );
    }

    emit(state.copyWith(blocks: validatedBlocks));
  }

  void corruptBlock(int index, String maliciousData) {
    if (state.isMining || index < 0 || index >= state.blocks.length) return;

    final corruptedBlocks = [...state.blocks];
    final block = corruptedBlocks[index];
    corruptedBlocks[index] = Block(
      index: block.index,
      hash: block.hash,
      previousHash: block.previousHash,
      nonce: block.nonce,
      difficulty: block.difficulty,
      data: maliciousData,
      isValid: false,
      isCorrupted: true,
    );
    emit(state.copyWith(blocks: corruptedBlocks));
    validateChain();
  }

  Future<void> repairChain(int fromIndex) async {
    if (state.isMining || state.blocks.isEmpty) return;

    final startIndex =
        fromIndex.clamp(0, state.blocks.length - 1).toInt();
    final startedAt = DateTime.now();
    final repairedBlocks = [...state.blocks];
    var previousHash =
        startIndex == 0 ? '0' * 64 : repairedBlocks[startIndex - 1].hash;
    var totalHashes = 0;
    emit(
      state.copyWith(
        isMining: true,
        miningNonce: 0,
        miningHash: '',
        hashesChecked: 0,
        lastDuration: Duration.zero,
      ),
    );

    for (var index = startIndex; index < repairedBlocks.length; index++) {
      final oldBlock = repairedBlocks[index];
      final result = await _mineBlock(
        index: oldBlock.index,
        previousHash: previousHash,
        difficulty: oldBlock.difficulty,
        data: oldBlock.data,
        previousHashesChecked: totalHashes,
      );
      totalHashes += result.hashesChecked;
      repairedBlocks[index] = result.block;
      previousHash = result.block.hash;
    }

    emit(
      state.copyWith(
        blocks: repairedBlocks,
        isMining: false,
        miningNonce: repairedBlocks.last.nonce,
        miningHash: repairedBlocks.last.hash,
        hashesChecked: totalHashes,
        lastDuration: DateTime.now().difference(startedAt),
      ),
    );
    validateChain();
  }

  Future<_MiningResult> _mineBlock({
    required int index,
    required String previousHash,
    required int difficulty,
    required String data,
    int previousHashesChecked = 0,
  }) async {
    final target = '0' * difficulty;
    var nonce = 0;
    var hashesChecked = 0;
    var hash = '';

    do {
      hash = _hashBlock(index, previousHash, nonce, difficulty, data);
      hashesChecked++;
      nonce++;

      if (hashesChecked % 128 == 0) {
        emit(
          state.copyWith(
            miningNonce: nonce,
            miningHash: hash,
            hashesChecked: previousHashesChecked + hashesChecked,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      }
    } while (!hash.startsWith(target));

    return _MiningResult(
      block: Block(
        index: index,
        hash: hash,
        previousHash: previousHash,
        nonce: nonce - 1,
        difficulty: difficulty,
        data: data,
      ),
      hashesChecked: hashesChecked,
    );
  }

  String _hashBlock(
    int index,
    String previousHash,
    int nonce,
    int difficulty,
    String data,
  ) {
    final payload = '$index:$previousHash:$nonce:$difficulty:$data';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}

class _MiningResult {
  const _MiningResult({required this.block, required this.hashesChecked});

  final Block block;
  final int hashesChecked;
}
