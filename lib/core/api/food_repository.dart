import 'package:dio/dio.dart';
import 'package:macrolite/core/domain/food_product.dart';

class FoodRepository {
  final Dio _dio;
  FoodRepository(this._dio);

  final _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  Future<FoodProduct> getFoodByBarcode(String barcode) async {
    final url = '$_baseUrl/product/$barcode.json';

    try {
      final response = await _dio.get(url);

      if (response.data['status'] == 0) {
        throw Exception('Ürün bulunamadı: ${response.data['status_verbose']}');
      }

      return FoodProduct.fromJson(response.data);

    } on DioException catch (e) {
      throw Exception('API isteği başarısız: ${e.message}');
    } catch (e) {
      throw Exception('Beklenmedik bir hata oluştu: $e');
    }
  }
}