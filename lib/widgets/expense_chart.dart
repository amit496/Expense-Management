import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;
  final bool showLegend;

  const ExpenseChart({
    super.key,
    required this.data,
    this.showLegend = true,
  });

  static const List<Color> chartColors = [
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFFD946EF),
    Color(0xFF0EA5E9),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline,
                  size: 48,
                  color: isDark ? Colors.white12 : Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                'No data to display',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections:
                  data.entries.toList().asMap().entries.map((e) {
                final index = e.key;
                final entry = e.value;
                final percentage = (entry.value / total * 100);

                return PieChartSectionData(
                  value: entry.value,
                  title: percentage >= 10
                      ? '${percentage.toStringAsFixed(0)}%'
                      : '',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  radius: 55,
                  color: chartColors[index % chartColors.length],
                );
              }).toList(),
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children:
                data.entries.toList().asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: chartColors[index % chartColors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
