import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/block.dart';

enum ConsensusType { pow, pos }

class ChainState {
  const ChainState({
    this.blocks = const [],
    this.isMining = false,
    this.miningNonce = 0,
    this.miningHash = '',
    this.hashesChecked = 0,
    this.lastDuration = Duration.zero,
    this.consensusType = ConsensusType.pow,
    this.selectedValidator = '',
  });

  final List<Block> blocks;
  final bool isMining;
  final int miningNonce;
  final String miningHash;
  final int hashesChecked;
  final Duration lastDuration;
  final ConsensusType consensusType;
  final String selectedValidator;

  ChainState copyWith({
    List<Block>? blocks,
    bool? isMining,
    int? miningNonce,
    String? miningHash,
    int? hashesChecked,
    Duration? lastDuration,
    ConsensusType? consensusType,
    String? selectedValidator,
  }) {
    return ChainState(
      blocks: blocks ?? this.blocks,
      isMining: isMining ?? this.isMining,
      miningNonce: miningNonce ?? this.miningNonce,
      miningHash: miningHash ?? this.miningHash,
      hashesChecked: hashesChecked ?? this.hashesChecked,
      lastDuration: lastDuration ?? this.lastDuration,
      consensusType: consensusType ?? this.consensusType,
      selectedValidator: selectedValidator ?? this.selectedValidator,
    );
  }
}

class ChainCubit extends Cubit<ChainState> {
  ChainCubit() : super(const ChainState());

  static const validators = ['Alpha', 'Beta', 'Gamma'];

  void toggleConsensus(ConsensusType type) {
    if (state.isMining || state.consensusType == type) return;
    emit(
      state.copyWith(
        consensusType: type,
        selectedValidator: type == ConsensusType.pos ? state.selectedValidator : '',
      ),
    );
  }

  Future<void> addDemoBlock({int difficulty = 2}) async {
    if (state.isMining) return;

    final previous = state.blocks.isEmpty ? '0' * 64 : state.blocks.last.hash;
    final index = state.blocks.length;
    final startedAt = DateTime.now();
    final transactions = _transactionsFor(index);

    emit(
      state.copyWith(
        isMining: true,
        miningNonce: 0,
        miningHash: '',
        hashesChecked: 0,
        lastDuration: Duration.zero,
      ),
    );

    final result = state.consensusType == ConsensusType.pow
        ? await _mineBlock(
            index: index,
            previousHash: previous,
            difficulty: difficulty,
            data: 'BlockCore transaction #$index',
            transactions: transactions,
          )
        : await _forgePosBlock(
            index: index,
            previousHash: previous,
            data: 'BlockCore transaction #$index',
            transactions: transactions,
          );
    emit(
      state.copyWith(
        blocks: [...state.blocks, result.block],
        isMining: false,
        miningNonce: result.block.nonce,
        miningHash: result.block.hash,
        hashesChecked: result.hashesChecked,
        lastDuration: DateTime.now().difference(startedAt),
        selectedValidator: result.block.validator,
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
            block.merkleRoot,
            block.validator,
          ) ==
          block.hash;
      final merkleMatches = _merkleRoot(block.transactions) == block.merkleRoot;
      final previousMatches = block.previousHash == expectedPreviousHash;
      final consensusMatches = block.validator.isNotEmpty ||
          block.hash.startsWith('0' * block.difficulty);
      final isValid =
          chainIsValid &&
          hashMatches &&
          merkleMatches &&
          previousMatches &&
          consensusMatches;
      chainIsValid = isValid;
      validatedBlocks.add(
        Block(
          index: block.index,
          hash: block.hash,
          previousHash: block.previousHash,
          nonce: block.nonce,
          difficulty: block.difficulty,
          data: block.data,
          transactions: block.transactions,
          merkleRoot: block.merkleRoot,
          validator: block.validator,
          isValid: isValid,
          isCorrupted: block.isCorrupted || !hashMatches || !merkleMatches,
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
      transactions: block.transactions,
      merkleRoot: block.merkleRoot,
      validator: block.validator,
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
      final result = state.consensusType == ConsensusType.pow
          ? await _mineBlock(
              index: oldBlock.index,
              previousHash: previousHash,
              difficulty: oldBlock.difficulty,
              data: oldBlock.data,
              transactions: oldBlock.transactions,
              previousHashesChecked: totalHashes,
            )
          : await _forgePosBlock(
              index: oldBlock.index,
              previousHash: previousHash,
              data: oldBlock.data,
              transactions: oldBlock.transactions,
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
        selectedValidator: state.consensusType == ConsensusType.pos
            ? repairedBlocks.last.validator
            : '',
      ),
    );
    validateChain();
  }

  Future<_MiningResult> _mineBlock({
    required int index,
    required String previousHash,
    required int difficulty,
    required String data,
    required List<String> transactions,
    int previousHashesChecked = 0,
  }) async {
    final target = '0' * difficulty;
    var nonce = 0;
    var hashesChecked = 0;
    var hash = '';

    do {
      final merkleRoot = _merkleRoot(transactions);
      hash = _hashBlock(
        index,
        previousHash,
        nonce,
        difficulty,
        data,
        merkleRoot,
        '',
      );
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
        transactions: transactions,
        merkleRoot: _merkleRoot(transactions),
      ),
      hashesChecked: hashesChecked,
    );
  }

  Future<_MiningResult> _forgePosBlock({
    required int index,
    required String previousHash,
    required String data,
    required List<String> transactions,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final validator = validators[Random().nextInt(validators.length)];
    final merkleRoot = _merkleRoot(transactions);
    final hash = _hashBlock(
      index,
      previousHash,
      0,
      0,
      data,
      merkleRoot,
      validator,
    );
    return _MiningResult(
      block: Block(
        index: index,
        hash: hash,
        previousHash: previousHash,
        nonce: 0,
        difficulty: 0,
        data: data,
        transactions: transactions,
        merkleRoot: merkleRoot,
        validator: validator,
      ),
      hashesChecked: 0,
    );
  }

  List<String> _transactionsFor(int index) {
    return ['Tx$index-A', 'Tx$index-B', 'Tx$index-C'];
  }

  String _merkleRoot(List<String> transactions) {
    if (transactions.isEmpty) return sha256.convert(utf8.encode('')).toString();

    var level = transactions.map(_hashText).toList();
    while (level.length > 1) {
      final next = <String>[];
      for (var index = 0; index < level.length; index += 2) {
        final right = index + 1 < level.length ? level[index + 1] : level[index];
        next.add(_hashText('${level[index]}$right'));
      }
      level = next;
    }
    return level.single;
  }

  String _hashText(String value) =>
      sha256.convert(utf8.encode(value)).toString();

  String _hashBlock(
    int index,
    String previousHash,
    int nonce,
    int difficulty,
    String data,
    String merkleRoot,
    String validator,
  ) {
    final payload =
        '$index:$previousHash:$nonce:$difficulty:$data:$merkleRoot:$validator';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}

class _MiningResult {
  const _MiningResult({required this.block, required this.hashesChecked});

  final Block block;
  final int hashesChecked;
}
