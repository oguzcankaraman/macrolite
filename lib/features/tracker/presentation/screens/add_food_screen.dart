import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/core/utils/validators.dart';
import 'package:macrolite/features/tracker/application/recipe_notifier.dart';
import 'package:macrolite/features/tracker/presentation/screens/create_recipe_screen.dart';
import 'package:macrolite/features/tracker/presentation/widgets/add_recipe_sheet.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});
  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Manual Form State
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submitManualForm() {
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

      ref
          .read(trackerNotifierProvider.notifier)
          .addFoodToMeal(_selectedMeal, newFood);
      context.pop();
    }
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
              Tab(text: 'Manuel'),
              Tab(text: 'Tarifler'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildManualForm(theme), _buildRecipesList(theme)],
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

  Widget _buildManualForm(ThemeData theme) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(theme, 'Genel Bilgiler'),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Öğün',
              value: _selectedMeal,
              items: ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün'],
              onChanged: (val) => setState(() => _selectedMeal = val!),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Yiyecek Adı',
              hint: 'Örn: Yumurta',
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Lütfen bir yiyecek adı girin.'
                  : null,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(theme, 'Porsiyon'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Miktar',
                    hint: '100',
                    keyboardType: TextInputType.number,
                    validator: numericValidator,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<FoodUnit>(
                    value: _selectedUnit,
                    decoration: _inputDecoration('Birim'),
                    items: FoodUnit.values
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedUnit = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(theme, 'Besin Değerleri'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _caloriesController,
              label: 'Kalori (kcal)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: numericValidator,
              suffixText: 'kcal',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _proteinController,
                    label: 'Protein',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _carbsController,
                    label: 'Karb',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    suffixText: 'g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _fatController,
                    label: 'Yağ',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    suffixText: 'g',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitManualForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, hint: hint, suffixText: suffixText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label),
      items: items
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      onChanged: onChanged,
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
