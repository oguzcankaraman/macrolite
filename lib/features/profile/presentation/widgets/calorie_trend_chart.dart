import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macrolite/features/tracker/application/daily_summaries_provider.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:shimmer/shimmer.dart';

class CalorieTrendChart extends ConsumerWidget {
  const CalorieTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 29)); // Last 30 days

    final summariesAsync = ref.watch(
      dailySummariesProvider(start: start, end: today),
    );
    final profileAsync = ref.watch(profileNotifierProvider);

    return summariesAsync.when(
      data: (summaries) {
        return profileAsync.when(
          data: (profile) {
            final targetCalories = profile.targetCalories;

            if (summaries.isEmpty) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            // Create a map of dates to calories
            final dataMap = {
              for (var s in summaries)
                DateTime(s.date.year, s.date.month, s.date.day): s.calories,
            };

            // Generate data points for all 30 days
            final spots = <FlSpot>[];
            double maxCalories = targetCalories;
            double totalCalories = 0;
            int daysWithData = 0;

            for (int i = 0; i < 30; i++) {
              final date = start.add(Duration(days: i));
              final normalizedDate = DateTime(date.year, date.month, date.day);
              final calories = dataMap[normalizedDate] ?? 0.0;

              spots.add(FlSpot(i.toDouble(), calories));
              if (calories > maxCalories) maxCalories = calories;
              if (calories > 0) {
                totalCalories += calories;
                daysWithData++;
              }
            }

            final averageCalories = daysWithData > 0
                ? totalCalories / daysWithData
                : 0.0;

            // Ensure chart has proper bounds
            final chartMaxY = maxCalories > 0 ? maxCalories * 1.2 : 100.0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calorie Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLegendItem(
                          'Target',
                          '${targetCalories.toInt()} kcal',
                          Colors.red.shade300,
                        ),
                        const SizedBox(width: 16),
                        _buildLegendItem(
                          'Average',
                          '${averageCalories.toInt()} kcal',
                          Colors.purple.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: chartMaxY,
                          lineBarsData: [
                            // Actual calories line
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.blue.shade600,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400.withOpacity(0.3),
                                    Colors.blue.shade600.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Target line
                            LineChartBarData(
                              spots: [
                                FlSpot(0, targetCalories),
                                FlSpot(29, targetCalories),
                              ],
                              isCurved: false,
                              color: Colors.red.shade300,
                              barWidth: 2,
                              dashArray: [5, 5],
                              dotData: const FlDotData(show: false),
                            ),
                            // Average line
                            if (averageCalories > 0)
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, averageCalories),
                                  FlSpot(29, averageCalories),
                                ],
                                isCurved: false,
                                color: Colors.purple.shade300,
                                barWidth: 2,
                                dashArray: [5, 5],
                                dotData: const FlDotData(show: false),
                              ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 7,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 7 != 0) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = start.add(
                                    Duration(days: value.toInt()),
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat('M/d').format(date),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                                reservedSize: 28,
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
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: chartMaxY / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (spot) => Colors.blue.shade700,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  if (spot.barIndex != 0) {
                                    return null; // Only show tooltip for actual data
                                  }
                                  final date = start.add(
                                    Duration(days: spot.x.toInt()),
                                  );
                                  return LineTooltipItem(
                                    '${DateFormat('MMM d').format(date)}\n${spot.y.toInt()} kcal',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 24, color: Colors.white),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 80, height: 16, color: Colors.white),
                        const SizedBox(width: 16),
                        Container(width: 80, height: 16, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          error: (error, stack) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 250,
              child: Center(child: Text('Error loading profile: $error')),
            ),
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 24, color: Colors.white),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 80, height: 16, color: Colors.white),
                    const SizedBox(width: 16),
                    Container(width: 80, height: 16, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          height: 250,
          child: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
