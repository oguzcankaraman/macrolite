import 'package:hive/hive.dart';

part 'weight_entry.g.dart';

@HiveType(typeId: 5)
class WeightEntry {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double weight;

  const WeightEntry({required this.date, required this.weight});

  WeightEntry copyWith({DateTime? date, double? weight}) {
    return WeightEntry(date: date ?? this.date, weight: weight ?? this.weight);
  }
}
