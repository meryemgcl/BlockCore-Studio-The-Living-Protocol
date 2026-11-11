import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
    var nonce = 0;
    var hashesChecked = 0;
    var hash = '';
    final target = '0' * difficulty;

    emit(
      state.copyWith(
        isMining: true,
        miningNonce: 0,
        miningHash: '',
        hashesChecked: 0,
        lastDuration: Duration.zero,
      ),
    );

    do {
      hash = _hashBlock(index, previous, nonce, difficulty);
      hashesChecked++;
      nonce++;

      if (hashesChecked % 128 == 0) {
        emit(
          state.copyWith(
            miningNonce: nonce,
            miningHash: hash,
            hashesChecked: hashesChecked,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      }
    } while (!hash.startsWith(target));

    final block = Block(
      index: index,
      hash: hash,
      previousHash: previous,
      nonce: nonce - 1,
      difficulty: difficulty,
    );
    emit(
      state.copyWith(
        blocks: [...state.blocks, block],
        isMining: false,
        miningNonce: block.nonce,
        miningHash: block.hash,
        hashesChecked: hashesChecked,
        lastDuration: DateTime.now().difference(startedAt),
      ),
    );
  }

  String _hashBlock(
    int index,
    String previousHash,
    int nonce,
    int difficulty,
  ) {
    final payload = '$index:$previousHash:$nonce:$difficulty';
    return sha256.convert(utf8.encode(payload)).toString();
  }
}
