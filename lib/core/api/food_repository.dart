import 'package:dio/dio.dart';
import 'package:macrolite/core/domain/food_product.dart';

class FoodRepository {
  final Dio _dio;
  FoodRepository(this._dio);

  final _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  Future<FoodProduct?> getFoodByBarcode(String barcode) async {
    final url = '$_baseUrl/product/$barcode.json';

    try {
      final response = await _dio.get(url);

      // FoodProduct.fromJson exception fırlatırsa null döndür
      try {
        return FoodProduct.fromJson(response.data);
      } catch (e) {
        // fromJson'dan gelen tüm exception'lar için null döndür
        return null;
      }

    } on DioException catch (e) {
      throw Exception('API isteği başarısız: ${e.message}');
    }
  }
}
