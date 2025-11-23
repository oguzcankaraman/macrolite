import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/tracker/application/tracker_providers.dart';
import 'package:macrolite/features/tracker/application/recipe_notifier.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';
import 'package:macrolite/features/tracker/presentation/screens/manual_food_form.dart';

class UniversalFoodSearch extends ConsumerStatefulWidget {
  final Function(FoodItem) onFoodSelected;
  final Function(Recipe)? onRecipeSelected;
  final String? mealName; // Optional, passed to ManualFoodForm if needed

  const UniversalFoodSearch({
    super.key,
    required this.onFoodSelected,
    this.onRecipeSelected,
    this.mealName,
  });

  @override
  ConsumerState<UniversalFoodSearch> createState() =>
      _UniversalFoodSearchState();
}

class _UniversalFoodSearchState extends ConsumerState<UniversalFoodSearch> {
  String _searchQuery = '';
  bool _isSearchingRemote = false;
  List<FoodItem> _foodResults = [];
  List<Recipe> _recipeResults = [];
  bool _showRemoteButton = false;

  @override
  void initState() {
    super.initState();
    _performLocalSearch();
  }

  void _performLocalSearch() async {
    final foodRepo = ref.read(foodRepositoryProvider);
    final recipes = ref.read(recipeNotifierProvider).valueOrNull ?? [];

    if (_searchQuery.isEmpty) {
      // Show history
      final history = foodRepo.getRecentFoods();
      setState(() {
        _foodResults = history;
        _recipeResults =
            recipes; // Show all recipes or maybe recent? Let's show all for now or filter
        _showRemoteButton = false;
      });
    } else {
      // Search local foods
      final localFoods = await foodRepo.search(_searchQuery);

      // Search local recipes
      final localRecipes = recipes
          .where(
            (r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();

      setState(() {
        _foodResults = localFoods;
        _recipeResults = localRecipes;
        // Show remote button if there is a query, regardless of local results
        _showRemoteButton = true;
      });
    }
  }

  final Set<String> _performedSearches = {};

  void _performRemoteSearch() async {
    if (_searchQuery.isEmpty) return;

    // Prevent duplicate searches
    if (_performedSearches.contains(_searchQuery.toLowerCase())) {
      return;
    }

    setState(() => _isSearchingRemote = true);
    final repo = ref.read(foodRepositoryProvider);
    try {
      final remote = await repo.search(_searchQuery, forceRemote: true);

      // Add to cache on success
      _performedSearches.add(_searchQuery.toLowerCase());

      setState(() {
        _foodResults = remote;
        _isSearchingRemote = false;
      });
    } catch (e) {
      setState(() => _isSearchingRemote = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Yiyecek veya Tarif Ara',
              hintText: 'Örn: Yumurta, Pilav',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
                _isSearchingRemote = false;
              });
              _performLocalSearch();
            },
            onSubmitted: (_) =>
                _performRemoteSearch(), // Search online on Enter
          ),
        ),
        Expanded(child: _buildResultList()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final newFood = await Navigator.push<FoodItem>(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualFoodForm(
                    mealName: widget.mealName ?? 'Yeni Yiyecek',
                  ),
                ),
              );

              if (newFood != null) {
                widget.onFoodSelected(newFood);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Yiyecek Tanımla'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultList() {
    if (_isSearchingRemote) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_foodResults.isEmpty &&
        _recipeResults.isEmpty &&
        _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Yerel sonuç bulunamadı.'),
            TextButton(
              onPressed: _performRemoteSearch,
              child: const Text('İnternette Ara'),
            ),
          ],
        ),
      );
    }

    final totalCount =
        _recipeResults.length +
        _foodResults.length +
        (_showRemoteButton ? 1 : 0);

    return ListView.builder(
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Show Recipes First
        if (index < _recipeResults.length) {
          final recipe = _recipeResults[index];
          return ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
            title: Text(recipe.name),
            subtitle: Text('${recipe.totalCalories.round()} kcal / 100g'),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () {
              if (widget.onRecipeSelected != null) {
                widget.onRecipeSelected!(recipe);
              } else {
                // Fallback: Convert recipe to FoodItem and select
                final foodItem = FoodItem(
                  id: recipe.id,
                  name: recipe.name,
                  calories: recipe.totalCalories
                      .toDouble(), // Fixed: cast to double
                  protein: recipe.totalProtein,
                  carbs: recipe.totalCarbs,
                  fat: recipe.totalFat,
                  unit: 'gram',
                  baseAmount: 100,
                );
                widget.onFoodSelected(foodItem);
              }
            },
          );
        }

        final foodIndex = index - _recipeResults.length;

        // Show Foods
        if (foodIndex < _foodResults.length) {
          final food = _foodResults[foodIndex];
          return ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.blue),
            title: Text(food.name),
            subtitle: Text(
              '${food.baseAmount} ${food.unit} = ${food.calories.round()} kcal',
            ),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () => widget.onFoodSelected(food),
          );
        }

        // Show Remote Button
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: _performRemoteSearch,
            child: const Text('Daha Fazla Sonuç Göster (Online)'),
          ),
        );
      },
    );
  }
}
