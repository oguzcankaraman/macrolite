import 'package:flutter/material.dart';
import 'package:macrolite/core/domain/macro_data.dart';

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({super.key, required this.summaryData});

  final List<MacroData> summaryData;

  @override
  Widget build(BuildContext context) {
    // Find specific macro data
    // Note: TrackerNotifier uses Turkish labels
    final calories = summaryData.firstWhere(
      (d) => d.label == 'Kalori' || d.label == 'Calories',
      orElse: () => const MacroData(
        label: 'Calories',
        currentValue: 0,
        targetValue: 2000,
      ),
    );
    final protein = summaryData.firstWhere(
      (d) => d.label == 'Protein',
      orElse: () =>
          const MacroData(label: 'Protein', currentValue: 0, targetValue: 150),
    );
    final carbs = summaryData.firstWhere(
      (d) => d.label == 'Karbonhidrat' || d.label == 'Carbs',
      orElse: () =>
          const MacroData(label: 'Carbs', currentValue: 0, targetValue: 200),
    );
    final fat = summaryData.firstWhere(
      (d) => d.label == 'Yağ' || d.label == 'Fat',
      orElse: () =>
          const MacroData(label: 'Fat', currentValue: 0, targetValue: 70),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calories Progress (Large)
            _buildCalorieProgress(context, calories),
            const SizedBox(height: 24),
            // Macros Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem(context, protein, Colors.blue),
                _buildMacroItem(context, carbs, Colors.orange),
                _buildMacroItem(context, fat, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieProgress(BuildContext context, MacroData data) {
    final progress = (data.currentValue / data.targetValue).clamp(0.0, 1.0);
    final remaining = (data.targetValue - data.currentValue).toInt();
    final isOver = data.currentValue > data.targetValue;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${data.currentValue.toInt()} / ${data.targetValue.toInt()} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isOver
                      ? '${(data.currentValue - data.targetValue).toInt()} over'
                      : '$remaining left',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOver ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOver ? Colors.red : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(BuildContext context, MacroData data, Color color) {
    final progress = (data.currentValue / data.targetValue).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${data.currentValue.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'g',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          '/${data.targetValue.toInt()}g',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
