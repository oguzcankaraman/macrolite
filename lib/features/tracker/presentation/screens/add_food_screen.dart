import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/tracker/application/recipe_notifier.dart';
import 'package:macrolite/features/tracker/presentation/screens/create_recipe_screen.dart';
import 'package:macrolite/features/tracker/presentation/widgets/add_recipe_sheet.dart';

import 'package:macrolite/features/tracker/presentation/widgets/food_quantity_sheet.dart';
import 'package:macrolite/features/tracker/presentation/widgets/universal_food_search.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});
  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Manual Form State
  String _selectedMeal = 'Kahvaltı';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yiyecek Ekle'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Yiyecekler'),
              Tab(text: 'Tarifler'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildSearchInterface(theme), _buildRecipesList(theme)],
        ),
      ),
    );
  }

  Widget _buildRecipesList(ThemeData theme) {
    final recipesAsync = ref.watch(recipeNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedMeal,
            decoration: _inputDecoration('Öğün Seçin'),
            items: ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün']
                .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedMeal = val!),
          ),
        ),
        Expanded(
          child: recipesAsync.when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Henüz kayıtlı tarif yok.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateRecipeScreen(),
                            ),
                          );
                        },
                        child: const Text('Yeni Tarif Oluştur'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        recipe.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${recipe.totalCalories} kcal / 100g (Tahmini)',
                      ),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddRecipeSheet(
                            recipe: recipe,
                            mealName: _selectedMeal,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Hata: $e')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRecipeScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Tarif Oluştur'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ],
    );
  }

  // Search State

  Widget _buildSearchInterface(ThemeData theme) {
    return UniversalFoodSearch(
      mealName: _selectedMeal,
      onFoodSelected: (food) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              FoodQuantitySheet(food: food, mealName: _selectedMeal),
        );
      },
      onRecipeSelected: (recipe) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              AddRecipeSheet(recipe: recipe, mealName: _selectedMeal),
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
