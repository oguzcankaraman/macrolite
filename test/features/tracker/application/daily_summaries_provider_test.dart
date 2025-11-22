import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/domain/daily_macro_summary.dart';
import 'package:macrolite/features/tracker/application/daily_summaries_provider.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';

class FakeTrackerRepository implements TrackerRepository {
  @override
  Future<List<DailyMacroSummary>> getDailySummaries({
    required DateTime start,
    required DateTime end,
  }) async {
    return [
      DailyMacroSummary(
        date: start,
        calories: 500,
        protein: 30,
        carbs: 50,
        fat: 20,
      ),
    ];
  }

  @override
  Future<List<Meal>> getMeals(DateTime date) async => [];

  @override
  Future<List<Meal>> getMealsForDate(DateTime date) async => [];

  @override
  Future<void> saveMeals(DateTime date, List<Meal> meals) async {}
}

void main() {
  test('dailySummariesProvider returns data from repository', () async {
    final container = ProviderContainer(
      overrides: [
        trackerRepositoryProvider.overrideWithValue(FakeTrackerRepository()),
      ],
    );
    addTearDown(container.dispose);

    final start = DateTime(2023, 10, 1);
    final end = DateTime(2023, 10, 7);

    final summaries = await container.read(
      dailySummariesProvider(start: start, end: end).future,
    );

    expect(summaries.length, 1);
    expect(summaries.first.calories, 500);
    expect(summaries.first.date, start);
  });
}
