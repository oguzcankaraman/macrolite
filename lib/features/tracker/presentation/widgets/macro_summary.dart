import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrolite/core/domain/macro_data.dart';

class MacroSummary extends StatelessWidget {
  const MacroSummary({super.key, required this.data});
  final MacroData data;

  String _formatMacroValue(double value, String label) {
    if (label == 'Kalori') {
      return NumberFormat('#,##0', 'tr_TR').format(value);
    }
    return NumberFormat('#,##0.#', 'tr_TR').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final currentFormatted = _formatMacroValue(data.currentValue, data.label);
    final targetFormatted = _formatMacroValue(data.targetValue, data.label);

    final valueText = data.label == 'Kalori'
        ? '$currentFormatted / $targetFormatted'
        : '${currentFormatted}g / ${targetFormatted}g';

    return Column(
      children: [
        Text(data.label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(valueText, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: LinearProgressIndicator(
            value: data.progress,
            backgroundColor: Colors.grey[300],
            color: data.currentValue > data.targetValue ? Colors.redAccent : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
