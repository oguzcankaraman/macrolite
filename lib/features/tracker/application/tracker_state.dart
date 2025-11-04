import 'package:macrolite/core/domain/macro_data.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';

class TrackerState {
  final List<MacroData> summaryData;
  final List<Meal> meals;

  const TrackerState({ required this.summaryData, required this.meals });

  TrackerState copyWith({
    List<MacroData>? summaryData,
    List<Meal>? meals,
  }) {
    return TrackerState(
      summaryData: summaryData ?? this.summaryData,
      meals: meals ?? this.meals,
    );
  }
}