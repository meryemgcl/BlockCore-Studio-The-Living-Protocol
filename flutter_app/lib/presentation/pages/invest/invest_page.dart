import 'package:flutter/material.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../modals/search_modal.dart';
import '../../widgets/interactive_chart_widget.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  int selectedCategory = 0;
  final categories = ['All', 'Stocks', 'ETFs', 'Commodities', 'Bonds'];

  void _showStockDetails(StockItem stock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131927),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol, style: RevolutTheme.titleMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(stock.name, style: RevolutTheme.caption),
                  ],
                ),
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: RevolutTheme.monoNumeric.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1A2234), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('24h Değişim:', style: TextStyle(color: Colors.white54)),
                  Text(
                    '${stock.isUp ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: stock.isUp ? RevolutTheme.accentGreen : RevolutTheme.accentRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RevolutTheme.royalBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${stock.symbol} Hisse Alım Emri İletildi!')),
                  );
                },
                child: Text('${stock.symbol} Satın Al', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchModal(
        onSelectTransaction: (tx) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RevolutTheme.darkBackground,
      appBar: AppBar(
        title: Text('Invest', style: RevolutTheme.titleMedium),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(AppIcons.search, size: 20),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Varlık ve Sektör Filtreleme Seçenekleri')),
              );
            },
            icon: const Icon(AppIcons.filter, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildPortfolioSummary(),
          const SizedBox(height: 16),
          const InteractiveChartWidget(
            title: 'S&P 500 & RWA Tokenized Assets Index',
            lineColor: RevolutTheme.accentGreen,
            dataPoints: [4850.0, 4890.0, 4875.0, 4920.0, 4960.0, 4945.0, 5010.0, 5080.0, 5120.0, 5175.0, 5210.0, 5260.0],
            baseCurrencySymbol: '\$',
          ),
          const SizedBox(height: 20),
          _buildCategoryPills(),
          const SizedBox(height: 20),
          Text('Watchlist (Tap for Details)', style: RevolutTheme.titleMedium.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          _buildStockList(),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Investment', style: RevolutTheme.caption),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('\$4,250.80', style: RevolutTheme.heroBalance.copyWith(fontSize: 32)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RevolutTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.trendUp, color: RevolutTheme.accentGreen, size: 14),
                    const SizedBox(width: 4),
                    Text('+12.4%', style: RevolutTheme.caption.copyWith(color: RevolutTheme.accentGreen, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final isSelected = selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : RevolutTheme.cardSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStockList() {
    return Container(
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: MockData.watchlistStocks.map((stock) {
          return ListTile(
            onTap: () => _showStockDetails(stock),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E2638),
              child: Text(
                stock.symbol.substring(0, 2),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(stock.name, style: RevolutTheme.caption),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${stock.price.toStringAsFixed(2)}', style: RevolutTheme.monoNumeric),
                Text(
                  '${stock.isUp ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: stock.isUp ? RevolutTheme.accentGreen : RevolutTheme.accentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
