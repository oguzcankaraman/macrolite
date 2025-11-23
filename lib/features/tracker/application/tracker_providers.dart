import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/features/tracker/data/food_repository.dart';
import 'package:macrolite/features/tracker/data/open_food_facts_service.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';

final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final apiService = ref.watch(openFoodFactsServiceProvider);
  final box = Hive.box<FoodItem>('food_library');
  return FoodRepository(apiService, box);
});
