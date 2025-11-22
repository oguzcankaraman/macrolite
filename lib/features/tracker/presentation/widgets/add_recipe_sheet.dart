import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';

class AddRecipeSheet extends ConsumerStatefulWidget {
  final Recipe recipe;
  final String mealName;

  const AddRecipeSheet({
    super.key,
    required this.recipe,
    required this.mealName,
  });

  @override
  ConsumerState<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends ConsumerState<AddRecipeSheet> {
  final _amountController = TextEditingController();

  // Calculated values
  int _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateMacros);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateMacros() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final food = widget.recipe.toLoggedFood(amount);
    setState(() {
      _calories = food.calories;
      _protein = food.protein;
      _carbs = food.carbs;
      _fat = food.fat;
    });
  }

  void _add() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final food = widget.recipe.toLoggedFood(amount);
    ref
        .read(trackerNotifierProvider.notifier)
        .addFoodToMeal(widget.mealName, food);
    context.pop(); // Close sheet
    context
        .pop(); // Close AddFoodScreen (optional, but usually we want to go back to tracker)
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.recipe.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '100g için: ${(widget.recipe.toLoggedFood(100).calories)} kcal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Yenen Miktar (g)',
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroDisplay(label: 'Kalori', value: '$_calories', unit: 'kcal'),
              _MacroDisplay(label: 'Prot', value: '$_protein', unit: 'g'),
              _MacroDisplay(label: 'Karb', value: '$_carbs', unit: 'g'),
              _MacroDisplay(label: 'Yağ', value: '$_fat', unit: 'g'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _add,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Öğüne Ekle'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MacroDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroDisplay({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          '$value $unit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
