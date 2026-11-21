import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InteractiveChartWidget extends StatefulWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final String baseCurrencySymbol;
  final String title;

  const InteractiveChartWidget({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.baseCurrencySymbol = '\$',
    this.title = '',
  });

  @override
  State<InteractiveChartWidget> createState() => _InteractiveChartWidgetState();
}

class _InteractiveChartWidgetState extends State<InteractiveChartWidget> {
  int? touchedIndex;
  int selectedTimeframe = 0;
  final timeframes = ['1D', '1W', '1M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
    final points = widget.dataPoints;
    final minVal = points.reduce(min);
    final maxVal = points.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final currentDisplayPrice = touchedIndex != null
        ? points[touchedIndex!]
        : points.last;

    final isPositive = points.last >= points.first;
    final diff = points.last - points.first;
    final pct = (diff / points.first) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RevolutTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title.isNotEmpty ? widget.title : 'Canlı Fiyat Grafiği',
                style: RevolutTheme.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPositive ? RevolutTheme.accentGreen : RevolutTheme.accentRed).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${pct.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? RevolutTheme.accentGreen : RevolutTheme.accentRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Scrubbed / Current Price Display
          Text(
            '${widget.baseCurrencySymbol}${currentDisplayPrice.toStringAsFixed(2)}',
            style: RevolutTheme.monoNumeric.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            touchedIndex != null ? 'Parmağınızı grafikte kaydırıyorsunuz' : 'Son 24 saatlik canlı trend',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 18),
          // Chart Canvas
          SizedBox(
            height: 140,
            width: double.infinity,
            child: GestureDetector(
              onPanDown: (details) => _updateTouch(details.localPosition.dx),
              onPanUpdate: (details) => _updateTouch(details.localPosition.dx),
              onPanEnd: (_) => setState(() => touchedIndex = null),
              onPanCancel: () => setState(() => touchedIndex = null),
              child: CustomPaint(
                painter: _SparklinePainter(
                  points: points,
                  minVal: minVal,
                  range: range,
                  lineColor: widget.lineColor,
                  touchedIndex: touchedIndex,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Timeframe Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(timeframes.length, (i) {
              final isSel = selectedTimeframe == i;
              return GestureDetector(
                onTap: () => setState(() => selectedTimeframe = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timeframes[i],
                    style: TextStyle(
                      color: isSel ? Colors.black : Colors.white54,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _updateTouch(double localX) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final width = box.size.width - 40; // padding
    final step = width / (widget.dataPoints.length - 1);
    final index = (localX / step).round().clamp(0, widget.dataPoints.length - 1);
    setState(() => touchedIndex = index);
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final double minVal;
  final double range;
  final Color lineColor;
  final int? touchedIndex;

  _SparklinePainter({
    required this.points,
    required this.minVal,
    required this.range,
    required this.lineColor,
    required this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalized = (points[i] - minVal) / range;
      final y = size.height - (normalized * size.height * 0.8) - (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withOpacity(0.25),
        lineColor.withOpacity(0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line Stroke
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Touch Indicator
    if (touchedIndex != null && touchedIndex! < points.length) {
      final x = touchedIndex! * stepX;
      final normalized = (points[touchedIndex!] - minVal) / range;
      final y = size.height - (normalized * size.height * 0.8) - (size.height * 0.1);

      // Vertical guide line
      final guidePaint = Paint()
        ..color = Colors.white30
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), guidePaint);

      // Outer glow circle
      final glowPaint = Paint()
        ..color = lineColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 9, glowPaint);

      // Inner white dot
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
