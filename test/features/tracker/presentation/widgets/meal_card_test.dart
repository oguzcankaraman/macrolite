import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/presentation/widgets/meal_card.dart';
import 'package:macrolite/core/domain/food_unit.dart';

void main() {
  testWidgets('MealCard displays meal info correctly', (
    WidgetTester tester,
  ) async {
    final food = LoggedFood(
      name: 'Egg',
      calories: 140,
      protein: 6,
      carbs: 0.6,
      fat: 5,
      quantity: 2,
      unit: FoodUnit.piece,
    );

    final meal = Meal(name: 'Breakfast', loggedFoods: [food]);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MealCard(meal: meal, isToday: true)),
        ),
      ),
    );

    // Check Meal Name and Total Calories
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('140 kcal'), findsOneWidget); // 70 * 2

    // Expand the tile
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    // Check Food Details
    expect(find.text('Egg'), findsOneWidget);
    expect(find.text('2.0 adet'), findsOneWidget);
    expect(
      find.text('140 kcal'),
      findsNWidgets(2),
    ); // Once in header, once in list
  });

  testWidgets('MealCard shows delete button only when isToday is true', (
    WidgetTester tester,
  ) async {
    final food = LoggedFood(
      name: 'Egg',
      calories: 140,
      protein: 6,
      carbs: 0.6,
      fat: 5,
      quantity: 2,
      unit: FoodUnit.piece,
    );

    final meal = Meal(name: 'Breakfast', loggedFoods: [food]);

    // Test isToday = true
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(body: MealCard(meal: meal, isToday: true)),
        ),
      ),
    );

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    // Test isToday = false
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(body: MealCard(meal: meal, isToday: false)),
        ),
      ),
    );

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
