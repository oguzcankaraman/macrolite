import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/core/api/food_repository.dart';
import 'package:macrolite/core/domain/food_product.dart';
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
  static const Duration _barcodeTTL = Duration(seconds: 2);

  @override
  FutureOr<FoodProduct?> build() {
    return null;
  }

  bool canProcessBarcode(String barcode) {
    // Gate kontrolü: Başka bir işlem devam ediyorsa engelle
    if (_isHandling) return false;

    // Aynı barkod kontrolü: Son taranan barkod hala geçerliyse engelle
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

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(foodRepositoryProvider).getFoodByBarcode(barcode);
    });

    // İşlem tamamlandı, gate'i aç
    _isHandling = false;
  }

  void resetState() {
    state = const AsyncData(null);
    _isHandling = false;
    // Not: _lastScannedBarcode'u sıfırlamıyoruz, TTL süresince korunacak
  }

  void clearBarcodeCache() {
    _lastScannedBarcode = null;
  }
}
