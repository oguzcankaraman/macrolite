import 'package:hive/hive.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:uuid/uuid.dart';

part 'recipe.g.dart';

@HiveType(typeId: 20)
class Recipe {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<LoggedFood> ingredients;
  @HiveField(3)
  final double totalOutputWeight; // The total weight of the cooked dish
  @HiveField(4)
  final FoodUnit unit; // Usually gram or ml

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.totalOutputWeight,
    required this.unit,
  });

  factory Recipe.create({
    required String name,
    required List<LoggedFood> ingredients,
    required double totalOutputWeight,
    FoodUnit unit = FoodUnit.gram,
  }) {
    return Recipe(
      id: const Uuid().v4(),
      name: name,
      ingredients: ingredients,
      totalOutputWeight: totalOutputWeight,
      unit: unit,
    );
  }

  // Calculate total macros for the entire recipe
  int get totalCalories =>
      ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein =>
      ingredients.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs =>
      ingredients.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFat => ingredients.fold(0.0, (sum, item) => sum + item.fat);

  // Calculate macros for a specific portion (e.g., 100g of the cooked dish)
  LoggedFood toLoggedFood(double portionAmount) {
    final ratio = portionAmount / totalOutputWeight;

    return LoggedFood(
      name: name,
      quantity: portionAmount,
      unit: unit,
      calories: (totalCalories * ratio).round(),
      protein: double.parse((totalProtein * ratio).toStringAsFixed(1)),
      carbs: double.parse((totalCarbs * ratio).toStringAsFixed(1)),
      fat: double.parse((totalFat * ratio).toStringAsFixed(1)),
    );
  }
}
