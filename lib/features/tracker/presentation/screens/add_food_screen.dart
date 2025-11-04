import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/core/utils/validators.dart';
import '../widgets/macro_input_field.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});
  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '100');
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  String _selectedMeal = 'Kahvaltı';
  FoodUnit _selectedUnit = FoodUnit.gram;

  @override
  void dispose() {
    _quantityController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.tryParse(_quantityController.text) ?? 100.0;
      final name = _nameController.text;
      final calories = int.tryParse(_caloriesController.text) ?? 0;
      final protein = double.tryParse(_proteinController.text) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text) ?? 0.0;
      final fat = double.tryParse(_fatController.text) ?? 0.0;

      final newFood = LoggedFood(
        name: name,
        quantity: quantity,
        unit: _selectedUnit,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      ref.read(trackerNotifierProvider.notifier).addFoodToMeal(_selectedMeal, newFood);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Manuel Yiyecek Ekle')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ÖĞÜN SEÇİMİ
              DropdownButtonFormField<String>(
                initialValue: _selectedMeal,
                decoration: const InputDecoration(labelText: 'Öğün'),
                items: ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMeal = value);
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Yiyecek Adı'),
                validator: (v) => (v == null || v.isEmpty) ? 'Lütfen bir yiyecek adı girin.' : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Miktar'),
                      keyboardType: TextInputType.number,
                      validator: numericValidator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<FoodUnit>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Birim'),
                      items: FoodUnit.values
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedUnit = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Kalori (kcal)'),
                keyboardType: TextInputType.number,
                validator: numericValidator,
              ),
              const SizedBox(height: 16),
              // MAKRO GİRİŞLERİ
              Row(
                children: [
                  MacroInputField(
                    controller: _proteinController,
                    labelText: 'Protein (g)',
                  ),
                  const SizedBox(width: 8),
                  MacroInputField(
                    controller: _carbsController,
                    labelText: 'Karbonhidrat (g)',
                  ),
                  const SizedBox(width: 8),
                  MacroInputField(
                    controller: _fatController,
                    labelText: 'Yağ (g)',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submitForm, child: const Text('Kaydet')),
            ],
          ),
        ),
      ),
    );
  }
}