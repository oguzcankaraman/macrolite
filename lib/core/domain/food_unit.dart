import 'package:hive/hive.dart';

part 'food_unit.g.dart';

@HiveType(typeId: 0)
enum FoodUnit {
  @HiveField(0)
  gram('g'),
  @HiveField(1)
  milliliter('ml'),
  @HiveField(2)
  piece('adet'),
  @HiveField(3)
  serving('porsiyon');

  const FoodUnit(this.label);
  final String label;

  factory FoodUnit.fromString(String name) {
    return values.firstWhere(
          (value) => value.name == name,
      orElse: () => FoodUnit.gram,
    );
  }
}