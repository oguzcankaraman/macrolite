class FoodProduct {
  final String productName;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double servingQuantity;
  final String? servingSize;

  FoodProduct({
    required this.productName,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.servingQuantity = 0,
    this.servingSize,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    // ÖNCE status kontrolü - hata fırlat
    final status = json['status'];
    if (status == 0 || status == '0') {
      throw Exception('Product not found');
    }

    final product = json['product'];

    // Product null veya boş ise hata fırlat
    if (product == null || product.isEmpty) {
      throw Exception('Product data is null');
    }

    final nutriments = product['nutriments'] ?? {};
    final productName = product['product_name'] as String?;

    // Ürün adı boş veya null ise hata fırlat
    if (productName == null || productName.trim().isEmpty) {
      throw Exception('Product name is missing');
    }

    return FoodProduct(
      productName: productName,
      caloriesPer100g: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
      proteinPer100g: (nutriments['proteins_100g'] ?? 0).toDouble(),
      carbsPer100g: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      fatPer100g: (nutriments['fat_100g'] ?? 0).toDouble(),
      servingQuantity: (product['serving_quantity'] ?? 0).toDouble(),
      servingSize: product['serving_size'] as String?,
    );
  }
}
