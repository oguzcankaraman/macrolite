import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/tracker/data/recipe_repository.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';

final recipeNotifierProvider =
    StateNotifierProvider<RecipeNotifier, AsyncValue<List<Recipe>>>((ref) {
      final repository = ref.watch(recipeRepositoryProvider);
      return RecipeNotifier(repository);
    });

class RecipeNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final RecipeRepository _repository;

  RecipeNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      final recipes = await _repository.getAllRecipes();
      state = AsyncValue.data(recipes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _repository.saveRecipe(recipe);
      // Reload to ensure consistency
      await loadRecipes();
    } catch (e) {
      // Handle error (maybe show a snackbar in UI via a listener)
      print('Error adding recipe: $e');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _repository.deleteRecipe(id);
      await loadRecipes();
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }
}
