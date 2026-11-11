import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bloc/chain_cubit.dart';

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
      theme: ThemeData.dark(useMaterial3: true),
      home: const ChainExplorerPage(),
    );
  }
}

class ChainExplorerPage extends StatelessWidget {
  const ChainExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlockCore Studio')),
      body: BlocBuilder<ChainCubit, ChainState>(
        builder: (context, state) {
          if (state.blocks.isEmpty) {
            return const Center(child: Text('Zincir henüz boş.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.blocks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final block = state.blocks[index];
              return Card(
                child: ListTile(
                  title: Text('Blok #${block.index}'),
                  subtitle: Text('Hash: ${block.hash}\nNonce: ${block.nonce}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: context.read<ChainCubit>().addDemoBlock,
        icon: const Icon(Icons.bolt),
        label: const Text('Blok Kaz'),
      ),
    );
  }
}
