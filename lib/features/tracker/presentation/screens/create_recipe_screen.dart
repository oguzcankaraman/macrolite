import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/application/recipe_notifier.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';
import 'package:macrolite/core/utils/validators.dart';
import 'ingredient_scanner_screen.dart';
import 'search_ingredient_screen.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalWeightController = TextEditingController();

  List<LoggedFood> _ingredients = [];

  @override
  void dispose() {
    _nameController.dispose();
    _totalWeightController.dispose();
    super.dispose();
  }

  void _addIngredient() async {
    // Show choice dialog: Manual or Barcode
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Malzeme Ekle'),
        content: const Text('Nasıl eklemek istersiniz?'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'manual'),
            icon: const Icon(Icons.search),
            label: const Text('Ara / Ekle'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'barcode'),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Barkod Tara'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    LoggedFood? result;

    if (choice == 'manual') {
      result = await Navigator.push<LoggedFood>(
        context,
        MaterialPageRoute(builder: (context) => const SearchIngredientScreen()),
      );
    } else if (choice == 'barcode') {
      result = await Navigator.push<LoggedFood>(
        context,
        MaterialPageRoute(
          builder: (context) => const IngredientScannerScreen(),
        ),
      );
    }

    if (result != null) {
      setState(() {
        _ingredients.add(result!);
        _calculateTotalWeight();
      });
    }
  }

  void _calculateTotalWeight() {
    double total = 0;
    for (var food in _ingredients) {
      // Convert everything to grams for simplicity if needed, but assuming grams/ml are 1:1 for weight roughly
      total += food.quantity;
    }
    _totalWeightController.text = total.toStringAsFixed(0);
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir malzeme ekleyin.')),
        );
        return;
      }

      final name = _nameController.text;
      final totalWeight = double.tryParse(_totalWeightController.text) ?? 0;

      final recipe = Recipe.create(
        name: name,
        ingredients: _ingredients,
        totalOutputWeight: totalWeight,
      );

      ref.read(recipeNotifierProvider.notifier).addRecipe(recipe);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Tarif Oluştur')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tarif Adı',
                hintText: 'Örn: Pilav',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Lütfen bir isim girin' : null,
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Malzemeler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Henüz malzeme eklenmedi.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._ingredients.map(
                (food) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      '${food.quantity} ${food.unit.label} - ${food.calories} kcal',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredients.remove(food);
                          _calculateTotalWeight();
                        });
                      },
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            TextFormField(
              controller: _totalWeightController,
              decoration: const InputDecoration(
                labelText: 'Toplam Pişmiş Ağırlık (g)',
                hintText: 'Otomatik hesaplanır veya düzenleyin',
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
              validator: numericValidator,
            ),
            const SizedBox(height: 8),
            const Text(
              'Not: Pişirme sırasında su kaybı veya eklemesi (pirinç şişmesi gibi) olabileceği için son ağırlığı tartıp girmeniz en doğrusudur.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Tarifi Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddIngredientDialog extends StatefulWidget {
  const _AddIngredientDialog();

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  FoodUnit _unit = FoodUnit.gram;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Malzeme Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Adı'),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Miktar'),
                      keyboardType: TextInputType.number,
                      validator: numericValidator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<FoodUnit>(
                      value: _unit,
                      items: FoodUnit.values
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v!),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Kalori (kcal)'),
                keyboardType: TextInputType.number,
                validator: numericValidator,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: 'Prot (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(labelText: 'Karb (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Yağ (g)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final food = LoggedFood(
                name: _nameController.text,
                quantity: double.parse(_quantityController.text),
                unit: _unit,
                calories: int.parse(_caloriesController.text),
                protein: double.tryParse(_proteinController.text) ?? 0,
                carbs: double.tryParse(_carbsController.text) ?? 0,
                fat: double.tryParse(_fatController.text) ?? 0,
              );
              Navigator.pop(context, food);
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
