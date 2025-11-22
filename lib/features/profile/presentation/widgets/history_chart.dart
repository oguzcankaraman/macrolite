import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macrolite/features/tracker/application/daily_summaries_provider.dart';

class HistoryChart extends ConsumerWidget {
  const HistoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Last 7 days including today
    final end = today;
    final start = today.subtract(const Duration(days: 6));

    final summariesAsync = ref.watch(
      dailySummariesProvider(start: start, end: end),
    );

    return summariesAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No data available')),
          );
        }

        // Map summaries to a map for easy lookup by date
        final summaryMap = {
          for (var s in summaries)
            DateTime(s.date.year, s.date.month, s.date.day): s,
        };

        // Generate data points for the last 7 days, filling missing days with 0
        final List<BarChartGroupData> barGroups = [];
        double maxCalories = 0;

        for (int i = 0; i < 7; i++) {
          final date = start.add(Duration(days: i));
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final summary = summaryMap[normalizedDate];
          final calories = summary?.calories ?? 0.0;

          if (calories > maxCalories) maxCalories = calories;

          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: calories,
                  color: Colors.blueAccent,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        return AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCalories * 1.2, // Add some buffer
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = start.add(Duration(days: group.x.toInt()));
                      return BarTooltipItem(
                        '${DateFormat('MMM d').format(date)}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} kcal',
                            style: const TextStyle(color: Colors.yellowAccent),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = start.add(Duration(days: value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E').format(date), // Mon, Tue...
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          SizedBox(height: 200, child: Center(child: Text('Error: $error'))),
    );
  }
}
