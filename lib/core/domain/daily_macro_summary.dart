class DailyMacroSummary {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const DailyMacroSummary({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  String toString() {
    return 'DailyMacroSummary(date: $date, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyMacroSummary &&
        other.date == date &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        calories.hashCode ^
        protein.hashCode ^
        carbs.hashCode ^
        fat.hashCode;
  }
}
