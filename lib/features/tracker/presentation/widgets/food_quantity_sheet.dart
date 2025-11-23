import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';
import 'package:macrolite/features/tracker/application/tracker_providers.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';

class FoodQuantitySheet extends ConsumerStatefulWidget {
  final FoodItem food;
  final String? mealName; // Optional: If null, user must select a meal
  final Function(LoggedFood)? onSave;

  const FoodQuantitySheet({
    super.key,
    required this.food,
    this.mealName,
    this.onSave,
  });

  @override
  ConsumerState<FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState extends ConsumerState<FoodQuantitySheet> {
  final _quantityController = TextEditingController(text: '1');
  double _currentQuantity = 1.0;

  // Unit Selection
  late FoodUnit _selectedUnit;
  String _selectedMeal = 'Kahvaltı'; // Default meal if selection is needed

  @override
  void initState() {
    super.initState();

    // Initialize unit selection
    if (widget.food.unit != 'gram' && widget.food.unit != 'ml') {
      // If the base unit is NOT gram/ml (e.g. Adet), default to it.
      // We map this custom unit to FoodUnit.serving for calculation purposes,
      // treating "1 unit" as "1 serving".
      _selectedUnit = FoodUnit.serving;
    } else if (widget.food.servingUnit != null &&
        widget.food.servingSizeG != null) {
      // If we have a specific serving unit (e.g. Adet), default to it?
      // Or default to Gram? Let's default to Gram for consistency, but allow switch.
      _selectedUnit = FoodUnit.gram;
    } else {
      _selectedUnit = FoodUnit.gram;
    }

    _quantityController.addListener(() {
      final val = double.tryParse(_quantityController.text);
      if (val != null && val != _currentQuantity) {
        setState(() {
          _currentQuantity = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _addToMeal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity <= 0) return;

    double ratio;

    if (_selectedUnit == FoodUnit.serving) {
      // Dynamic serving unit (Adet, Dilim, etc.)
      if (widget.food.unit != 'gram' && widget.food.unit != 'ml') {
        // Custom base unit (e.g. Adet).
        ratio = quantity / widget.food.baseAmount;
      } else if (widget.food.servingSizeG != null) {
        // Gram-based food with serving info
        ratio = (quantity * widget.food.servingSizeG!) / widget.food.baseAmount;
      } else {
        // Fallback
        ratio = quantity / widget.food.baseAmount;
      }
    } else if (_selectedUnit == FoodUnit.milliliter) {
      // Assuming 1ml = 1g for simplicity if density unknown
      ratio = quantity / widget.food.baseAmount;
    } else {
      // Gram
      ratio = quantity / widget.food.baseAmount;
    }

    final loggedFood = LoggedFood(
      name: widget.food.name,
      quantity: quantity,
      unit: _selectedUnit,
      calories: (widget.food.calories * ratio).round(),
      protein: widget.food.protein * ratio,
      carbs: widget.food.carbs * ratio,
      fat: widget.food.fat * ratio,
    );

    // Save to local history for future searches
    ref.read(foodRepositoryProvider).saveFood(widget.food);

    if (widget.onSave != null) {
      widget.onSave!(loggedFood);
    } else {
      final targetMeal = widget.mealName ?? _selectedMeal;
      ref
          .read(trackerNotifierProvider.notifier)
          .addFoodToMeal(targetMeal, loggedFood);
    }
    context.pop(loggedFood); // Close sheet and return result
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasServingInfo = widget.food.servingSizeG != null;
    final servingLabel = widget.food.servingUnit ?? 'Porsiyon';

    // Calculate display values
    // Calculate display values
    double ratio;
    if (_selectedUnit == FoodUnit.serving) {
      if (widget.food.unit != 'gram' && widget.food.unit != 'ml') {
        // Custom base unit (e.g. Adet).
        // If selected unit is also that custom unit (mapped to FoodUnit.serving),
        // then ratio is just quantity / baseAmount.
        // Example: 1 Adet / 1 Adet = 1.
        ratio = _currentQuantity / widget.food.baseAmount;
      } else if (hasServingInfo) {
        // Gram-based food with serving info
        ratio =
            (_currentQuantity * widget.food.servingSizeG!) /
            widget.food.baseAmount;
      } else {
        // Fallback
        ratio = _currentQuantity / widget.food.baseAmount;
      }
    } else {
      // Gram or Ml selected
      ratio = _currentQuantity / widget.food.baseAmount;
    }

    final totalCals = (widget.food.calories * ratio).round();
    final totalProtein = (widget.food.protein * ratio).toStringAsFixed(1);
    final totalCarbs = (widget.food.carbs * ratio).toStringAsFixed(1);
    final totalFat = (widget.food.fat * ratio).toStringAsFixed(1);

    String unitDisplayLabel = 'Gram';
    if (_selectedUnit == FoodUnit.milliliter) unitDisplayLabel = 'Ml';
    if (_selectedUnit == FoodUnit.serving) {
      if (widget.food.unit != 'gram' && widget.food.unit != 'ml') {
        unitDisplayLabel = widget.food.unit;
      } else {
        unitDisplayLabel =
            '$servingLabel (${widget.food.servingSizeG!.round()}g)';
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.food.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Baz: ${widget.food.baseAmount} ${widget.food.unit} = ${widget.food.calories.round()} kcal',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Unit Selection Chips
          // Unit Selection Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Only show Gram/Ml if the food is weight-based OR has serving weight info
                if (widget.food.unit == 'gram' ||
                    widget.food.unit == 'ml' ||
                    hasServingInfo) ...[
                  _buildUnitChip('Gram', FoodUnit.gram),
                  const SizedBox(width: 8),
                  _buildUnitChip('Mililitre', FoodUnit.milliliter),
                  const SizedBox(width: 8),
                ],

                // Show the custom unit (Adet, Serving, etc.)
                // If base unit is custom, show it.
                // If base unit is gram but has serving info, show serving option.
                if (widget.food.unit != 'gram' && widget.food.unit != 'ml')
                  _buildUnitChip(widget.food.unit, FoodUnit.serving)
                else if (hasServingInfo)
                  _buildUnitChip(servingLabel, FoodUnit.serving),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // Meal Selection (Only if mealName is null)
          if (widget.mealName == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedMeal,
                decoration: const InputDecoration(
                  labelText: 'Öğün',
                  border: OutlineInputBorder(),
                ),
                items: ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMeal = value);
                },
              ),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Miktar ($unitDisplayLabel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalCals kcal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'P: $totalProtein g  K: $totalCarbs g  Y: $totalFat g',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addToMeal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Öğüne Ekle'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUnitChip(String label, FoodUnit unit) {
    final isSelected = _selectedUnit == unit;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedUnit = unit;
            _quantityController.text = '1';
            _currentQuantity = 1.0;
          });
        }
      },
    );
  }
}
