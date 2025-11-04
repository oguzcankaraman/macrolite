
class FoodProduct {
  final String barcode;
  final String productName;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  FoodProduct({
    required this.barcode,
    required this.productName,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};

    return FoodProduct(
      barcode: json['code'] ?? 'No barcode',
      productName: product['product_name'] ?? 'Ürün Adı Bulunamadı',
      caloriesPer100g: double.tryParse(nutriments['energy-kcal_100g']?.toString() ?? '0.0') ?? 0.0,
      proteinPer100g: double.tryParse(nutriments['proteins_100g']?.toString() ?? '0.0') ?? 0.0,
      carbsPer100g: double.tryParse(nutriments['carbohydrates_100g']?.toString() ?? '0.0') ?? 0.0,
      fatPer100g: double.tryParse(nutriments['fat_100g']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}