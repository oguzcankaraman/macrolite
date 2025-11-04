// lib/features/scanner/presentation/widgets/product_found_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/core/domain/food_unit.dart'; // Yeni enum'ı import et
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';

class ProductFoundView extends ConsumerStatefulWidget {
  // GÜNCELLENDİ: scrollController parametresini ekliyoruz (bir önceki hatayı düzeltmek için)
  const ProductFoundView({
    super.key,
    required this.product,
    required this.scrollController,
  });

  final FoodProduct product;
  final ScrollController scrollController; // scrollController parametresi

  @override
  ConsumerState<ProductFoundView> createState() => _ProductFoundViewState();
}

class _ProductFoundViewState extends ConsumerState<ProductFoundView> {
  // Formu doğrulamak için bir key
  final _formKey = GlobalKey<FormState>();

  // Controller'ları tanımla
  final _quantityController = TextEditingController(
    text: '1.0',
  ); // Miktar (örn: 1.5 porsiyon)
  final _servingWeightController = TextEditingController(
    text: '100.0',
  ); // 1 porsiyonun gram/ml karşılığı

  String _selectedMeal = 'Kahvaltı';
  FoodUnit _selectedUnit =
      FoodUnit.gram; // Seçili birimi tutmak için state değişkeni

  @override
  void dispose() {
    _quantityController.dispose();
    _servingWeightController.dispose();
    super.dispose();
  }

  void _addFoodToList() {
    // Form geçerli değilse işlemi durdur
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;

    // YENİ VE DOĞRU HESAPLAMA MANTIĞI
    double totalWeightInGrams;

    if (_selectedUnit == FoodUnit.gram ||
        _selectedUnit == FoodUnit.milliliter) {
      // Eğer birim gram/ml ise, miktar doğrudan toplam ağırlıktır.
      totalWeightInGrams = quantity;
    } else {
      // Eğer birim porsiyon/adet ise, 1 porsiyonun ağırlığını alıp miktarla çarparız.
      final servingWeight =
          double.tryParse(_servingWeightController.text) ?? 100.0;
      totalWeightInGrams = quantity * servingWeight;
    }

    // Toplam ağırlığa göre makroları hesapla
    final calculatedCalories =
        (widget.product.caloriesPer100g / 100) * totalWeightInGrams;
    final calculatedProtein =
        (widget.product.proteinPer100g / 100) * totalWeightInGrams;
    final calculatedCarbs =
        (widget.product.carbsPer100g / 100) * totalWeightInGrams;
    final calculatedFat =
        (widget.product.fatPer100g / 100) * totalWeightInGrams;

    final newFood = LoggedFood(
      name: widget.product.productName,
      quantity: quantity,
      unit: _selectedUnit,
      // Artık bu birim, hesaplamayla tutarlı.
      calories: calculatedCalories.toInt(),
      protein: calculatedProtein,
      carbs: calculatedCarbs,
      fat: calculatedFat,
    );
    // Notifier'ı çağır
    ref
        .read(trackerNotifierProvider.notifier)
        .addFoodToMeal(_selectedMeal, newFood);
    // Modalı kapat
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Form doğrulama için
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        controller: widget.scrollController,
        // scrollController'ı ListView'a bağla
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            widget.product.productName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            '(${widget.product.caloriesPer100g.toInt()} kcal / 100g)',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // MİKTAR VE BİRİM SEÇİMİ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  // TextField -> TextFormField
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Miktar',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      (val == null ||
                          val.isEmpty ||
                          double.tryParse(val) == null)
                      ? 'Geçerli bir sayı girin'
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<FoodUnit>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Birim',
                    border: OutlineInputBorder(),
                  ),
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

          // YENİ: "PORSİYON" VEYA "ADET" SEÇİLİRSE GÖSTERİLECEK EK ALAN
          if (_selectedUnit == FoodUnit.serving ||
              _selectedUnit == FoodUnit.piece)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextFormField(
                controller: _servingWeightController,
                decoration: InputDecoration(
                  labelText: '1 ${_selectedUnit.label} ağırlığı (g/ml)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    (val == null || val.isEmpty || double.tryParse(val) == null)
                    ? 'Geçerli bir sayı girin'
                    : null,
              ),
            ),

          const SizedBox(height: 16),

          // ÖĞÜN SEÇİMİ
          DropdownButtonFormField<String>(
            initialValue: _selectedMeal,
            // initialValue yerine value kullanmak daha iyidir
            decoration: const InputDecoration(
              labelText: 'Öğün',
              border: OutlineInputBorder(),
            ),
            items: ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğün']
                .map(
                  (label) => DropdownMenuItem(value: label, child: Text(label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedMeal = value);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _addFoodToList,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Listeye Ekle'),
          ),
        ],
      ),
    );
  }
}
