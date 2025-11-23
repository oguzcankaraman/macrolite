import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 10) // Ensure this ID is unique
class FoodItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double calories; // Per base unit

  @HiveField(3)
  final double protein; // Per base unit

  @HiveField(4)
  final double carbs; // Per base unit

  @HiveField(5)
  final double fat; // Per base unit

  @HiveField(6)
  final String unit; // e.g., 'gram', 'adet', 'serving'

  @HiveField(7)
  final double baseAmount; // e.g., 100 for gram, 1 for adet

  @HiveField(8)
  final double? servingSizeG; // Optional: Weight of one serving in grams (e.g. 50g for 1 cookie)

  @HiveField(9)
  final String? servingUnit; // Optional: Name of the serving unit (e.g. "Adet", "Dilim", "Kutu")

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.unit,
    required this.baseAmount,
    this.servingSizeG,
    this.servingUnit,
  });
}
