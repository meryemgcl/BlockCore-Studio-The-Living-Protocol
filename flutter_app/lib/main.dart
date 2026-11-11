import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bloc/chain_cubit.dart';
import 'presentation/widgets/chain_canvas_view.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => ChainCubit(),
      child: const BlockCoreApp(),
    ),
  );
}

class BlockCoreApp extends StatelessWidget {
  const BlockCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockCore Studio',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B0F12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF53F2C2),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F12),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const ChainExplorerPage(),
    );
  }
}

class ChainExplorerPage extends StatelessWidget {
  const ChainExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChainCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BlockCore Studio'),
            Text(
              'AĞ DURUMU: ${_networkStatus(state)}',
              style: TextStyle(
                color: state.blocks.every((block) => block.isValid)
                    ? const Color(0xFF53F2C2)
                    : const Color(0xFFE53935),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          SegmentedButton<ConsensusType>(
            segments: const [
              ButtonSegment(value: ConsensusType.pow, label: Text('PoW')),
              ButtonSegment(value: ConsensusType.pos, label: Text('PoS')),
            ],
            selected: {state.consensusType},
            showSelectedIcon: false,
            onSelectionChanged: state.isMining
                ? null
                : (selection) {
                    if (selection.isNotEmpty) {
                      context
                          .read<ChainCubit>()
                          .toggleConsensus(selection.first);
                    }
                  },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 16),
            child: Icon(
              state.blocks.every((block) => block.isValid)
                  ? Icons.verified_user_outlined
                  : Icons.gpp_bad_outlined,
              color: state.blocks.every((block) => block.isValid)
                  ? const Color(0xFF53F2C2)
                  : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _MiningPanel(state: state),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LIVE CHAIN',
              style: TextStyle(
                color: Color(0xFF53F2C2),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ChainCanvasView(
            blocks: state.blocks,
            onCorruptBlock: context.read<ChainCubit>().corruptBlock,
          ),
          if (state.blocks.any((block) => !block.isValid)) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: state.isMining
                    ? null
                    : () {
                        final firstInvalid = state.blocks.indexWhere(
                          (block) => !block.isValid,
                        );
                        if (firstInvalid >= 0) {
                          context.read<ChainCubit>().repairChain(firstInvalid);
                        }
                      },
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Zinciri Yeniden Doğrula & Onar'),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isMining
            ? null
            : () => context.read<ChainCubit>().addDemoBlock(difficulty: 2),
        backgroundColor: const Color(0xFF53F2C2),
        foregroundColor: const Color(0xFF07100D),
        icon: state.isMining
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.bolt),
        label: Text(state.isMining ? 'MADENCİLİK SÜRÜYOR' : 'BLOK KAZ'),
      ),
    );
  }

  String _networkStatus(ChainState state) {
    return state.blocks.every((block) => block.isValid)
        ? 'GÜVENLİ (YEŞİL)'
        : 'ZİNCİR KIRILDI / TEHDİT (KIRMIZI)';
  }
}

class _MiningPanel extends StatelessWidget {
  const _MiningPanel({required this.state});

  final ChainState state;

  @override
  Widget build(BuildContext context) {
    final hash = state.miningHash.isEmpty ? 'Bekleniyor' : state.miningHash;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12191D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MINING CONSOLE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                state.isMining ? '● ACTIVE' : '● READY',
                style: TextStyle(
                  color: state.isMining
                      ? const Color(0xFFFFC857)
                      : const Color(0xFF53F2C2),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ConsensusBadge(state: state),
          const SizedBox(height: 20),
          Row(
            children: [
              _Metric(label: 'BLOCKS', value: '${state.blocks.length}'),
              _Metric(label: 'NONCE', value: '${state.miningNonce}'),
              _Metric(label: 'CHECKED', value: '${state.hashesChecked}'),
              _Metric(
                label: 'LAST RUN',
                value: state.lastDuration == Duration.zero
                    ? '--'
                    : '${state.lastDuration.inMilliseconds}ms',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            state.consensusType == ConsensusType.pow
                ? 'SHA-256  /  DIFFICULTY 02'
                : 'SLOT / EPOCH  /  VALIDATOR QUORUM',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            hash,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF53F2C2),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          if (state.consensusType == ConsensusType.pos &&
              state.selectedValidator.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Seçilen doğrulayıcı: ${state.selectedValidator}',
              style: const TextStyle(
                color: Color(0xFF53F2C2),
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConsensusBadge extends StatelessWidget {
  const _ConsensusBadge({required this.state});

  final ChainState state;

  @override
  Widget build(BuildContext context) {
    final isPow = state.consensusType == ConsensusType.pow;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isPow
            ? const Color(0xFF2A2518)
            : const Color(0xFF17352F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPow
              ? const Color(0xFFFFC857).withOpacity(.35)
              : const Color(0xFF53F2C2).withOpacity(.35),
        ),
      ),
      child: Text(
        isPow
            ? 'Konsensüs: Proof-of-Work (Yüksek CPU, Hashrate: ~1.2 KH/s)'
            : 'Konsensüs: Proof-of-Stake (Sıfır Enerji, Anlık Kesinleşme)',
        style: TextStyle(
          color: isPow ? const Color(0xFFFFC857) : const Color(0xFF53F2C2),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
