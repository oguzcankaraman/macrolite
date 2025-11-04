import 'package:hive/hive.dart';
import 'package:macrolite/core/domain/food_unit.dart';

part 'logged_food.g.dart';

@HiveType(typeId: 1)
class LoggedFood {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double quantity;
  @HiveField(2)
  final FoodUnit unit;
  @HiveField(3)
  final int calories;
  @HiveField(4)
  final double protein;
  @HiveField(5)
  final double carbs;
  @HiveField(6)
  final double fat;

  const LoggedFood({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  LoggedFood copyWith({
    String? name,
    double? quantity,
    FoodUnit? unit,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return LoggedFood(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit.name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory LoggedFood.fromJson(Map<String, dynamic> map) {
    return LoggedFood(
      name: map['name'] as String,
      quantity: map['quantity'] as double,
      unit: FoodUnit.fromString(map['unit'] as String),
      calories: map['calories'] as int,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
    );
  }

  @override
  String toString() {
    return 'LoggedFood(name: $name, quantity: $quantity, unit: ${unit.label}, calories: $calories)';
  }
}