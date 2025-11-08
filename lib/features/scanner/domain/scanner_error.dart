sealed class ScannerError {
  const ScannerError();

  String getMessage() {
    return switch (this) {
      ProductNotFoundError() => 'Ürün veritabanında bulunamadı',
      NetworkError() => 'Bağlantı sorunu. İnternet bağlantınızı kontrol edin',
      UnknownError() => 'Beklenmeyen bir hata oluştu',
    };
  }
}

class ProductNotFoundError extends ScannerError {
  const ProductNotFoundError();
}

class NetworkError extends ScannerError {
  const NetworkError();
}

class UnknownError extends ScannerError {
  const UnknownError();
}
