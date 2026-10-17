import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:allocation_feature/domain/entities/sector_allocation.dart';

class AllocationPieChart extends StatefulWidget {
  final List<SectorAllocation> allocations;
  final double totalValuation;
  final String? selectedSector;
  final ValueChanged<String> onSelectSector;

  const AllocationPieChart({
    super.key,
    required this.allocations,
    required this.totalValuation,
    required this.selectedSector,
    required this.onSelectSector,
  });

  @override
  State<AllocationPieChart> createState() => _AllocationPieChartState();
}

class _AllocationPieChartState extends State<AllocationPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.allocations.isEmpty || widget.totalValuation <= 0) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'No allocation data available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        if (event is FlTapUpEvent && _touchedIndex >= 0 && _touchedIndex < widget.allocations.length) {
                          widget.onSelectSector(widget.allocations[_touchedIndex].sector);
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2.5,
                  centerSpaceRadius: 65,
                  sections: List.generate(widget.allocations.length, (i) {
                    final alloc = widget.allocations[i];
                    final isTouched = i == _touchedIndex || widget.selectedSector == alloc.sector;
                    final fontSize = isTouched ? 14.0 : 11.0;
                    final radius = isTouched ? 48.0 : 40.0;
                    final color = Color(alloc.colorValue);

                    return PieChartSectionData(
                      color: color,
                      value: alloc.dollarValue,
                      title: '${alloc.percentage.toStringAsFixed(1)}%',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                      ),
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
              ),
              // Donut center label
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.selectedSector ?? 'Portfolio',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${widget.totalValuation.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Sector Legend Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.allocations.map((alloc) {
            final isSelected = widget.selectedSector == alloc.sector;
            final color = Color(alloc.colorValue);
            return FilterChip(
              selected: isSelected,
              avatar: CircleAvatar(backgroundColor: color, radius: 6),
              label: Text('${alloc.sector} (${alloc.percentage.toStringAsFixed(1)}%)'),
              onSelected: (_) => widget.onSelectSector(alloc.sector),
            );
          }).toList(),
        ),
      ],
    );
  }
}
