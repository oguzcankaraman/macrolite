import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

class RecipeRepository {
  static const String boxName = 'recipes';

  Future<Box<Recipe>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<Recipe>(boxName);
    }
    return Hive.box<Recipe>(boxName);
  }

  Future<List<Recipe>> getAllRecipes() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> saveRecipe(Recipe recipe) async {
    final box = await _openBox();
    await box.put(recipe.id, recipe);
  }

  Future<void> deleteRecipe(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
