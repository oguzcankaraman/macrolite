import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/utils/validators.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';

import 'package:macrolite/features/tracker/application/tracker_providers.dart';
import 'package:uuid/uuid.dart';

// We need a provider for FoodRepository.
// Since I haven't created a provider file for it yet, I'll assume one exists or create it here temporarily/globally.
// Ideally, this should be in a providers file.
// For now, I will assume `foodRepositoryProvider` will be created.

class ManualFoodForm extends ConsumerStatefulWidget {
  final String mealName;

  const ManualFoodForm({super.key, required this.mealName});

  @override
  ConsumerState<ManualFoodForm> createState() => _ManualFoodFormState();
}

class _ManualFoodFormState extends ConsumerState<ManualFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseAmountController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  String _selectedUnit = 'gram';

  @override
  void dispose() {
    _nameController.dispose();
    _baseAmountController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final baseAmount = double.tryParse(_baseAmountController.text) ?? 100.0;
      final calories = double.tryParse(_caloriesController.text) ?? 0.0;
      final protein = double.tryParse(_proteinController.text) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text) ?? 0.0;
      final fat = double.tryParse(_fatController.text) ?? 0.0;

      final newFood = FoodItem(
        id: const Uuid().v4(),
        name: name,
        unit: _selectedUnit,
        baseAmount: baseAmount,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      // Save to Repository
      ref.read(foodRepositoryProvider).saveFood(newFood);

      // Return the new food to the previous screen
      if (mounted) {
        Navigator.pop(context, newFood);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Yiyecek Tanımla')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Bu yiyeceği bir kez tanımlayın, daha sonra kütüphanenizden hızlıca ekleyin.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Yiyecek Adı',
                hintText: 'Örn: Ev Yapımı Köfte',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v?.isEmpty ?? true) ? 'Zorunlu alan' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Baz Miktar',
                      hintText: '1',
                      border: OutlineInputBorder(),
                    ),
                    validator: numericValidator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Birim',
                      border: OutlineInputBorder(),
                    ),
                    items: ['gram', 'adet', 'ml', 'porsiyon']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Besin Değerleri (Baz Miktar İçin)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kalori (kcal)',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
              ),
              validator: numericValidator,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Protein',
                      border: OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Karb',
                      border: OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Yağ',
                      border: OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Logic to be connected with provider
                // For now, just pass the object to the sheet directly?
                // But we need to SAVE it.
                // I will implement the save logic in the next step when I have the provider.
                // For now, I'll just navigate to show the UI works.
                _saveAndContinue();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kaydet ve Kullan'),
            ),
          ],
        ),
      ),
    );
  }
}
