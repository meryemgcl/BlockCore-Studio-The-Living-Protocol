import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/block.dart';

class ChainState {
  const ChainState({this.blocks = const []});

  final List<Block> blocks;
}

class ChainCubit extends Cubit<ChainState> {
  ChainCubit() : super(const ChainState());

  void addDemoBlock() {
    final previous = state.blocks.isEmpty ? '0' * 64 : state.blocks.last.hash;
    final index = state.blocks.length;
    emit(
      ChainState(
        blocks: [
          ...state.blocks,
          Block(
            index: index,
            hash: 'demo-${index.toString().padLeft(2, '0')}',
            previousHash: previous,
            nonce: 0,
            difficulty: 1,
          ),
        ],
      ),
    );
  }
}
