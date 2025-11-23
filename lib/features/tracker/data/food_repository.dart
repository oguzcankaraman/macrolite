import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/features/tracker/data/open_food_facts_service.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';

class FoodRepository {
  final OpenFoodFactsService _apiService;
  final Box<FoodItem> _localBox;

  FoodRepository(this._apiService, this._localBox);

  // Search Priority: Local -> Remote (if empty or requested)
  Future<List<FoodItem>> search(
    String query, {
    bool forceRemote = false,
  }) async {
    if (query.isEmpty) return [];

    // 1. Search Local
    final localResults = _localBox.values.where((food) {
      return food.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // 2. If local results exist and we are not forcing remote, return them
    if (localResults.isNotEmpty && !forceRemote) {
      return localResults;
    }

    // 3. If forceRemote is FALSE, return local results (even if empty)
    if (!forceRemote) {
      return localResults;
    }

    // 4. If forceRemote is TRUE, call API

    try {
      final remoteResults = await _apiService.searchFood(query);

      // We do NOT automatically save all remote results to local.
      // We only save them when the user actually *selects* (uses) them.
      // This prevents polluting the DB with irrelevant search results.

      if (forceRemote) {
        // If forced, maybe show both? Or just remote?
        // Let's return combined unique list if possible, or just remote.
        // User asked for "Show More", so likely wants remote.
        return remoteResults;
      }

      return remoteResults;
    } catch (e) {
      // If API fails, return local results (if any) or empty
      return localResults;
    }
  }

  Future<void> saveFood(FoodItem food) async {
    // Check if already exists to avoid duplicates
    final exists = _localBox.values.any(
      (f) =>
          f.name.toLowerCase() == food.name.toLowerCase() &&
          f.unit == food.unit &&
          f.baseAmount == food.baseAmount,
    );

    if (!exists) {
      await _localBox.add(food);
    }
  }

  List<FoodItem> getRecentFoods() {
    // Return last 20 added foods, reversed
    if (_localBox.isEmpty) return [];
    final list = _localBox.values.toList();
    if (list.length > 20) {
      return list.sublist(list.length - 20).reversed.toList();
    }
    return list.reversed.toList();
  }
}
