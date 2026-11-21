import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';

class SplitBillModal extends StatefulWidget {
  const SplitBillModal({super.key});

  @override
  State<SplitBillModal> createState() => _SplitBillModalState();
}

class _SplitBillModalState extends State<SplitBillModal> {
  double totalBill = 60.0;
  int personCount = 3;
  double tipPercent = 10.0;

  @override
  Widget build(BuildContext context) {
    final tipAmount = totalBill * (tipPercent / 100);
    final grandTotal = totalBill + tipAmount;
    final perPerson = grandTotal / personCount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF131927),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Split Bill & Share', style: RevolutTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Total bill input row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toplam Hesap:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                      onPressed: () {
                        if (totalBill > 10) setState(() => totalBill -= 10);
                      },
                    ),
                    Text('\$${totalBill.toStringAsFixed(0)}', style: RevolutTheme.monoNumeric.copyWith(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                      onPressed: () => setState(() => totalBill += 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Persons row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2234),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kişi Sayısı: $personCount kişi', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white54, size: 18),
                      onPressed: () {
                        if (personCount > 2) setState(() => personCount -= 1);
                      },
                    ),
                    Text('$personCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white54, size: 18),
                      onPressed: () {
                        if (personCount < 10) setState(() => personCount += 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Result Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: RevolutTheme.royalBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RevolutTheme.royalBlue.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                const Text('Kişi Başı Düşen Pay', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '\$${perPerson.toStringAsFixed(2)}',
                  style: RevolutTheme.heroBalance.copyWith(fontSize: 32, color: RevolutTheme.accentGreen),
                ),
                const SizedBox(height: 4),
                Text('Toplam \$${grandTotal.toStringAsFixed(2)} ($personCount eşit paya bölündü)',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Ödeme Talebi Linki Oluştur & Paylaş', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kişi başı \$${perPerson.toStringAsFixed(2)} ödeme linki panoya kopyalandı!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
