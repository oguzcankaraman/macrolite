import 'package:flutter/material.dart';

import 'package:macrolite/features/tracker/presentation/widgets/food_quantity_sheet.dart';
import 'package:macrolite/features/tracker/presentation/widgets/universal_food_search.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';

class SearchIngredientScreen extends StatelessWidget {
  const SearchIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Malzeme Ekle')),
      body: UniversalFoodSearch(
        onFoodSelected: (food) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => FoodQuantitySheet(
              food: food,
              mealName: '', // Not used for ingredients
              onSave: (loggedFood) {
                Navigator.pop(context, loggedFood); // Return from Sheet
                Navigator.pop(context, loggedFood); // Return from Screen
              },
            ),
          );
        },
        onRecipeSelected: (recipe) {
          // Convert recipe to FoodItem for ingredient usage
          final foodItem = FoodItem(
            id: recipe.id,
            name: recipe.name,
            calories: recipe.totalCalories.toDouble(),
            protein: recipe.totalProtein,
            carbs: recipe.totalCarbs,
            fat: recipe.totalFat,
            unit: 'gram',
            baseAmount: 100,
          );

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => FoodQuantitySheet(
              food: foodItem,
              mealName: '',
              onSave: (loggedFood) {
                Navigator.pop(context, loggedFood);
                Navigator.pop(context, loggedFood);
              },
            ),
          );
        },
      ),
    );
  }
}
