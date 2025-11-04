import 'package:macrolite/features/tracker/application/tracker_notifier.dart';

class MacroData {
  final String label;
  final double currentValue;
  final double targetValue;

  const MacroData({
    required this.label,
    required this.currentValue,
    required this.targetValue,
  });

  double get progress {
    if (targetValue == 0) {
      return 0.0;
    }
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  MacroData copyWith({
    String? label,
    double? currentValue,
    double? targetValue,
  }) {
    return MacroData(
      label: label ?? this.label,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
    );
  }
}