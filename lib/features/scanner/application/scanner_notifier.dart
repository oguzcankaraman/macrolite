import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/core/api/food_repository.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/domain/scanner_error.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

part 'scanner_notifier.g.dart';

@riverpod
MobileScannerController scannerController(Ref ref) {
  final controller = MobileScannerController(
    facing: CameraFacing.back,
    cameraResolution: const Size(1080, 720),
    detectionSpeed: DetectionSpeed.normal,
  );
  ref.onDispose(() => controller.dispose());
  return controller;
}

@riverpod
Dio dio(Ref ref) {
  return Dio();
}

@riverpod
FoodRepository foodRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FoodRepository(dio);
}

class _BarcodeCache {
  final String barcode;
  final DateTime timestamp;

  _BarcodeCache(this.barcode, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  _BarcodeCache? _lastScannedBarcode;
  bool _isHandling = false;
  String? _lastFailedBarcode;
  static const Duration _barcodeTTL = Duration(seconds: 2);

  @override
  FutureOr<FoodProduct?> build() {
    return null;
  }

  bool canProcessBarcode(String barcode) {
    if (_isHandling) return false;

    if (_lastScannedBarcode != null &&
        _lastScannedBarcode!.barcode == barcode &&
        !_lastScannedBarcode!.isExpired(_barcodeTTL)) {
      return false;
    }

    return true;
  }

  Future<void> fetchFood(String barcode) async {
    if (!canProcessBarcode(barcode)) return;

    _isHandling = true;
    _lastScannedBarcode = _BarcodeCache(barcode, DateTime.now());
    _lastFailedBarcode = null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final product = await ref.read(foodRepositoryProvider).getFoodByBarcode(barcode);

        if (product == null) {
          throw const ProductNotFoundError();
        }

        return product;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.error is SocketException) {
          throw const NetworkError();
        }

        if (e.response?.statusCode == 404) {
          throw const ProductNotFoundError();
        }

        throw const UnknownError();
      } catch (e) {
        if (e is ScannerError) rethrow;
        throw const UnknownError();
      }
    });

    if (state.hasError) {
      _lastFailedBarcode = barcode;
    }

    _isHandling = false;
  }

  Future<void> retryLastBarcode() async {
    if (_lastFailedBarcode != null) {
      final barcode = _lastFailedBarcode!;
      _lastScannedBarcode = null; // Cache'i temizle
      await fetchFood(barcode);
    }
  }

  void resetState() {
    state = const AsyncData(null);
    _isHandling = false;
    _lastFailedBarcode = null;
  }

  void clearBarcodeCache() {
    _lastScannedBarcode = null;
  }
}
