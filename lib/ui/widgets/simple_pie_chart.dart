import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SimplePieChart extends StatelessWidget {
  final Map<Color, double> data;
  final double radius;
  final double strokeWidth;
  final int? touchedIndex;
  final ValueChanged<int?>? onSectionTouched;

  const SimplePieChart({
    super.key,
    required this.data,
    this.radius = 60,
    this.strokeWidth = 24,
    this.touchedIndex,
    this.onSectionTouched,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: radius * 2, height: radius * 2);

    double total = data.values.fold(0, (sum, val) => sum + val);
    if (total <= 0) return SizedBox(width: radius * 2, height: radius * 2);

    List<PieChartSectionData> sections = [];
    int i = 0;
    for (final entry in data.entries) {
      if (entry.value <= 0) continue;

      final isTouched = i == touchedIndex;
      final currentStrokeWidth = isTouched ? strokeWidth + 6 : strokeWidth;

      sections.add(
        PieChartSectionData(
          color: entry.key,
          value: entry.value,
          radius: currentStrokeWidth,
          showTitle: false,
        ),
      );
      i++;
    }

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (onSectionTouched == null) return;
              if (event is FlTapUpEvent) {
                if (pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  onSectionTouched!(null);
                  return;
                }
                final index =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
                if (index >= 0) {
                  onSectionTouched!(index);
                } else {
                  onSectionTouched!(null);
                }
              }
            },
          ),
          sections: sections,
          sectionsSpace: 3, // Very clean gaps
          centerSpaceRadius: radius - strokeWidth,
          borderData: FlBorderData(show: false),
        ),
        duration: Duration(milliseconds: touchedIndex == null ? 600 : 150),
        curve: Curves.linear,
      ),
    );
  }
}
