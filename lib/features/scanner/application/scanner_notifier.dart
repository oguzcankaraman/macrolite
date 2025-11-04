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

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  @override
  FutureOr<FoodProduct?> build() {
    return null;
  }

  Future<void> fetchFood(String barcode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(foodRepositoryProvider).getFoodByBarcode(barcode);
    });
  }

  void resetState() {
    state = const AsyncData(null);
  }
}