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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BlockCore Studio'),
            Text(
              'PROTOCOL LAB / LOCAL NODE',
              style: TextStyle(fontSize: 10, letterSpacing: 1.6),
            ),
          ],
        ),
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
          ChainCanvasView(blocks: state.blocks),
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
            'SHA-256  /  DIFFICULTY 02',
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
        ],
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
