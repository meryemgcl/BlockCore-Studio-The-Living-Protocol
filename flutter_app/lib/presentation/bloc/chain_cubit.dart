import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/block.dart';
import '../../data/datasources/chain_local_storage.dart';
import '../../domain/usecases/isolated_miner.dart';

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
    this.miningDifficulty = 2,
    this.hashrate = '0 H/s',
  });

  final List<Block> blocks;
  final bool isMining;
  final int miningNonce;
  final String miningHash;
  final int hashesChecked;
  final Duration lastDuration;
  final ConsensusType consensusType;
  final String selectedValidator;
  final int miningDifficulty;
  final String hashrate;

  ChainState copyWith({
    List<Block>? blocks,
    bool? isMining,
    int? miningNonce,
    String? miningHash,
    int? hashesChecked,
    Duration? lastDuration,
    ConsensusType? consensusType,
    String? selectedValidator,
    int? miningDifficulty,
    String? hashrate,
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
      miningDifficulty: miningDifficulty ?? this.miningDifficulty,
      hashrate: hashrate ?? this.hashrate,
    );
  }
}

class ChainCubit extends Cubit<ChainState> {
  ChainCubit()
      : _storage = ChainLocalStorage(),
        super(const ChainState()) {
    _hydrated = _initialize();
  }

  static const validators = ['Alpha', 'Beta', 'Gamma'];
  final ChainLocalStorage _storage;
  late final Future<void> _hydrated;

  Future<void> _initialize() async {
    final blocks = await _storage.loadChain();
    if (!isClosed) emit(state.copyWith(blocks: blocks));
  }

  void toggleConsensus(ConsensusType type) {
    if (state.isMining || state.consensusType == type) return;
    emit(
      state.copyWith(
        consensusType: type,
        selectedValidator: type == ConsensusType.pos ? state.selectedValidator : '',
      ),
    );
  }

  void setDifficulty(int difficulty) {
    if (state.isMining || difficulty < 1 || difficulty > 4) return;
    emit(state.copyWith(miningDifficulty: difficulty));
  }

  Future<void> addDemoBlock() async {
    await _hydrated;
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
        hashrate: 'Hesaplanıyor...',
      ),
    );
    final result = state.consensusType == ConsensusType.pow
        ? await _mineBlock(
            index: index,
            previousHash: previous,
            difficulty: state.miningDifficulty,
            data: 'BlockCore transaction #$index',
            transactions: transactions,
          )
        : await _forgePosBlock(
            index: index,
            previousHash: previous,
            data: 'BlockCore transaction #$index',
            transactions: transactions,
          );

    final elapsed = DateTime.now().difference(startedAt);
    final elapsedSec = elapsed.inMicroseconds / 1000000.0;
    final hps = elapsedSec > 0 ? (result.hashesChecked / elapsedSec) : 0.0;
    final hashrateStr = hps >= 1000
        ? '${(hps / 1000).toStringAsFixed(1)} KH/s'
        : '${hps.toStringAsFixed(0)} H/s';

    emit(
      state.copyWith(
        blocks: [...state.blocks, result.block],
        isMining: false,
        miningNonce: result.block.nonce,
        miningHash: result.block.hash,
        hashesChecked: result.hashesChecked,
        lastDuration: elapsed,
        selectedValidator: result.block.validator,
        hashrate: state.consensusType == ConsensusType.pow ? hashrateStr : '0 H/s (PoS)',
      ),
    );
    await _storage.saveChain(state.blocks);
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
    unawaited(_storage.saveChain(corruptedBlocks));
    validateChain();
  }

  Future<void> repairChain(int fromIndex) async {
    await _hydrated;
    if (state.isMining || state.blocks.isEmpty) return;

    final startIndex = fromIndex.clamp(0, state.blocks.length - 1).toInt();
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
        hashrate: 'Onarılıyor...',
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

    final elapsed = DateTime.now().difference(startedAt);
    emit(
      state.copyWith(
        blocks: repairedBlocks,
        isMining: false,
        miningNonce: repairedBlocks.last.nonce,
        miningHash: repairedBlocks.last.hash,
        hashesChecked: totalHashes,
        lastDuration: elapsed,
        selectedValidator: state.consensusType == ConsensusType.pos
            ? repairedBlocks.last.validator
            : '',
        hashrate: 'Tamamlandı',
      ),
    );
    await _storage.saveChain(repairedBlocks);
    validateChain();
  }

  Future<void> resetChain() async {
    await _hydrated;
    if (state.isMining) return;
    await _storage.clearChain();
    emit(
      state.copyWith(
        blocks: const [],
        miningNonce: 0,
        miningHash: '',
        hashesChecked: 0,
        lastDuration: Duration.zero,
        hashrate: '0 H/s',
        selectedValidator: '',
      ),
    );
  }

  Future<_MiningResult> _mineBlock({
    required int index,
    required String previousHash,
    required int difficulty,
    required String data,
    required List<String> transactions,
  }) async {
    final merkleRoot = _merkleRoot(transactions);
    
    // Ağır madencilik CPU yükü Isolate.run() ile arka plan işletim sistemi thread'inde koşar!
    // UI thread'i asla bloklanmaz (120 FPS akıcılık garantisi).
    final output = await IsolatedMiner.mine(
      MiningParams(
        index: index,
        previousHash: previousHash,
        difficulty: difficulty,
        data: data,
        merkleRoot: merkleRoot,
      ),
    );

    return _MiningResult(
      block: output.block.copyWith(transactions: transactions),
      hashesChecked: output.hashesChecked,
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

extension BlockExtension on Block {
  Block copyWith({
    List<String>? transactions,
  }) {
    return Block(
      index: index,
      hash: hash,
      previousHash: previousHash,
      nonce: nonce,
      difficulty: difficulty,
      data: data,
      transactions: transactions ?? this.transactions,
      merkleRoot: merkleRoot,
      validator: validator,
      isValid: isValid,
      isCorrupted: isCorrupted,
    );
  }
}
