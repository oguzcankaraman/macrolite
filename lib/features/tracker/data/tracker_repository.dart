import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/core/domain/daily_macro_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

part 'tracker_repository.g.dart';

class TrackerRepository {
  TrackerRepository();

  String _boxNameForDate(DateTime date) {
    return 'meals_${DateFormat('yyyy-MM-dd').format(date)}';
  }

  Future<Box<Meal>> _openBoxForDate(DateTime date) async {
    final boxName = _boxNameForDate(date);
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Meal>(boxName);
    }
    return await Hive.openBox<Meal>(boxName);
  }

  Future<List<Meal>> getMeals(DateTime date) async {
    final box = await _openBoxForDate(date);
    return box.values.toList();
  }

  Future<List<Meal>> getMealsForDate(DateTime date) => getMeals(date);

  Future<void> saveMeals(DateTime date, List<Meal> meals) async {
    final box = await _openBoxForDate(date);
    await box.clear();
    await box.addAll(meals);
  }

  Future<List<DailyMacroSummary>> getDailySummaries({
    required DateTime start,
    required DateTime end,
  }) async {
    final summaries = <DailyMacroSummary>[];
    // Normalize dates to midnight to avoid time issues
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    for (
      var d = startDate;
      d.isBefore(endDate) || d.isAtSameMomentAs(endDate);
      d = d.add(const Duration(days: 1))
    ) {
      double calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;

      // We use _boxNameForDate to check if box exists without opening it if possible,
      // but Hive.boxExists is async.
      // However, _openBoxForDate handles opening.
      // Optimization: If we could check existence before opening, it might be faster for empty days.
      // But for now, we'll just open it as requested.

      final boxName = _boxNameForDate(d);
      if (await Hive.boxExists(boxName)) {
        final box = await _openBoxForDate(d);
        final meals = box.values;
        for (var meal in meals) {
          calories += meal.totalCalories;
          protein += meal.totalProtein;
          carbs += meal.totalCarbs;
          fat += meal.totalFat;
        }
      }
      // If box doesn't exist, values remain 0.

      summaries.add(
        DailyMacroSummary(
          date: d,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
        ),
      );
    }
    return summaries;
  }
}

@riverpod
TrackerRepository trackerRepository(TrackerRepositoryRef ref) {
  return TrackerRepository();
}
