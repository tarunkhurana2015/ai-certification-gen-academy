import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:analytics_feature/domain/entities/performance_metrics.dart';
import 'package:analytics_feature/l10n/analytics_localizations.dart';

class EquityCurveChart extends StatelessWidget {
  final List<HistoricalDataPoint> points;
  final String selectedTimeframe;
  final ValueChanged<String> onSelectTimeframe;

  const EquityCurveChart({
    super.key,
    required this.points,
    required this.selectedTimeframe,
    required this.onSelectTimeframe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AnalyticsLocalizations.of(context);

    if (points.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(
          height: 280,
          child: Center(child: Text('No historical data available for current portfolio.')),
        ),
      );
    }

    final minVal = points.map((p) => p.portfolioValue).reduce((a, b) => a < b ? a : b);
    final maxVal = points.map((p) => p.portfolioValue).reduce((a, b) => a > b ? a : b);
    final isGaining = points.last.portfolioValue >= points.first.portfolioValue;
    final curveColor = isGaining ? const Color(0xFF00C805) : theme.colorScheme.error;

    final portfolioSpots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].portfolioValue),
    );

    final benchmarkSpots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].benchmarkValue),
    );

    final timeframes = ['1M', '3M', '6M', '1Y', 'ALL'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header & Timeframe Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.equityGrowth ?? 'Equity Growth Trajectory',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Comparing portfolio equity against S&P 500 baseline',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  children: timeframes.map((tf) {
                    final isSelected = selectedTimeframe == tf;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(tf, style: const TextStyle(fontSize: 12)),
                      onSelected: (_) => onSelectTimeframe(tf),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Line Chart
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minY: minVal * 0.95,
                  maxY: maxVal * 1.05,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isPortfolio = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${isPortfolio ? "Portfolio: " : "Benchmark: "}\$${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: isPortfolio ? curveColor : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxVal - minVal) / 4 > 0 ? (maxVal - minVal) / 4 : 1000,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: (points.length / 4).clamp(1.0, 50.0),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < points.length) {
                            final d = points[idx].timestamp;
                            return Text(
                              '${d.month}/${d.day}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Portfolio Growth Line
                    LineChartBarData(
                      spots: portfolioSpots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: curveColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            curveColor.withValues(alpha: 0.25),
                            curveColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    // S&P 500 Benchmark Line
                    LineChartBarData(
                      spots: benchmarkSpots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: theme.colorScheme.outline.withValues(alpha: 0.6),
                      barWidth: 2,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
              ),
            ),
            const SizedBox(height: 12),

            // Legend Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 16, height: 3, color: curveColor),
                const SizedBox(width: 6),
                const Text('Portfolio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Container(
                  width: 16,
                  height: 2,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'S&P 500 Baseline',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
