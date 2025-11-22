import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';

void main() {
  late TrackerRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(LoggedFoodAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MealAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(FoodUnitAdapter());

    repository = TrackerRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  group('TrackerRepository', () {
    test('getDailySummaries aggregates data correctly over a range', () async {
      final date1 = DateTime(2023, 10, 1);
      final date2 = DateTime(2023, 10, 2);
      final date3 = DateTime(2023, 10, 3); // Empty day

      final food1 = LoggedFood(
        name: 'Apple',
        quantity: 1,
        unit: FoodUnit.piece,
        calories: 100,
        protein: 0.5,
        carbs: 25,
        fat: 0.3,
      );

      final food2 = LoggedFood(
        name: 'Chicken',
        quantity: 100,
        unit: FoodUnit.gram,
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
      );

      // Day 1: 2 meals
      await repository.saveMeals(date1, [
        Meal(name: 'Breakfast', loggedFoods: [food1]),
        Meal(name: 'Lunch', loggedFoods: [food2]),
      ]);

      // Day 2: 1 meal
      await repository.saveMeals(date2, [
        Meal(name: 'Dinner', loggedFoods: [food1, food1]), // 2 apples
      ]);

      // Act
      final summaries = await repository.getDailySummaries(
        start: date1,
        end: date3,
      );

      // Assert
      expect(summaries.length, 3);

      // Day 1 Check
      expect(summaries[0].date, date1);
      expect(summaries[0].calories, 265); // 100 + 165
      expect(summaries[0].protein, 31.5); // 0.5 + 31
      expect(summaries[0].carbs, 25); // 25 + 0
      expect(summaries[0].fat, 3.9); // 0.3 + 3.6

      // Day 2 Check
      expect(summaries[1].date, date2);
      expect(summaries[1].calories, 200); // 100 + 100
      expect(summaries[1].protein, 1.0); // 0.5 + 0.5

      // Day 3 Check (Empty)
      expect(summaries[2].date, date3);
      expect(summaries[2].calories, 0);
      expect(summaries[2].protein, 0);
    });

    test('getDailySummaries handles single day range', () async {
      final date = DateTime(2023, 10, 1);
      await repository.saveMeals(date, [
        Meal(
          name: 'Snack',
          loggedFoods: [
            LoggedFood(
              name: 'Egg',
              quantity: 1,
              unit: FoodUnit.piece,
              calories: 70,
              protein: 6,
              carbs: 0.6,
              fat: 5,
            ),
          ],
        ),
      ]);

      final summaries = await repository.getDailySummaries(
        start: date,
        end: date,
      );

      expect(summaries.length, 1);
      expect(summaries[0].calories, 70);
    });
  });
}
