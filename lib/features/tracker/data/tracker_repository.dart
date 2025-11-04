import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
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

  Future<void> saveMeals(DateTime date, List<Meal> meals) async {
    final box = await _openBoxForDate(date);
    await box.clear();
    await box.addAll(meals);
  }
}

@riverpod
TrackerRepository trackerRepository(TrackerRepositoryRef ref) {
  return TrackerRepository();
}