class FoodException implements Exception {
  final String message;
  const FoodException(this.message);
}

class ProductNotFoundException extends FoodException {
  const ProductNotFoundException() : super('Ürün bulunamadı');
}

class NetworkException extends FoodException {
  const NetworkException() : super('Bağlantı sorunu');
}
