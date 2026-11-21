import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class SearchModal extends StatefulWidget {
  final Function(TransactionItem) onSelectTransaction;

  const SearchModal({super.key, required this.onSelectTransaction});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  String query = '';
  int selectedCategoryIndex = 0;
  final categories = ['All', 'Transactions', 'Crypto', 'Blocks'];

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = MockData.recentTransactions.where((tx) {
      final q = query.toLowerCase();
      return tx.title.toLowerCase().contains(q) ||
          tx.fromCurrency.toLowerCase().contains(q) ||
          tx.toCurrency.toLowerCase().contains(q) ||
          tx.amount.toLowerCase().contains(q) ||
          tx.subtitle.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2234),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(AppIcons.search, color: Colors.white54, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search transaction, hash, token or block...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() => query = val);
                          },
                        ),
                      ),
                      if (query.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => query = ''),
                          child: const Icon(Icons.cancel, color: Colors.white54, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category Filter Pills
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final isSelected = selectedCategoryIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategoryIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF1A2234),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            query.isEmpty ? 'Recent On-Chain Activity' : 'Search Results (${filteredTransactions.length})',
            style: RevolutTheme.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(AppIcons.search, size: 40, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          'No on-chain records match "$query"',
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (ctx, idx) {
                      final item = filteredTransactions[idx];
                      return TransactionTile(
                        item: item,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelectTransaction(item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
