import 'package:hive/hive.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';

part 'meal.g.dart';

@HiveType(typeId: 2)
class Meal {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<LoggedFood> loggedFoods;

  const Meal({required this.name, required this.loggedFoods});

  int get totalCalories => loggedFoods.fold(0, (sum, food) => sum + food.calories);
  double get totalProtein => loggedFoods.fold(0.0, (sum, food) => sum + food.protein);
  double get totalCarbs => loggedFoods.fold(0.0, (sum, food) => sum + food.carbs);
  double get totalFat => loggedFoods.fold(0.0, (sum, food) => sum + food.fat);


  Meal copyWith({
    String? name,
    List<LoggedFood>? loggedFoods,
  }) {
    return Meal(
      name: name ?? this.name,
      loggedFoods: loggedFoods ?? this.loggedFoods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'loggedFoods': loggedFoods.map((food) => food.toJson()).toList(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      loggedFoods: (map['loggedFoods'] as List)
          .map((foodJson) => LoggedFood.fromJson(foodJson))
          .toList(),
    );
  }
}