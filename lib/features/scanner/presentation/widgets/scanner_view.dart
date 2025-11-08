import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:macrolite/features/scanner/domain/scanner_error.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'loading_view.dart';
import 'scanner_error_view.dart';
import 'scanner_overlay.dart';

class ScannerView extends ConsumerWidget {
  const ScannerView({
    super.key,
    required this.controller,
    required this.scannerState,
    required this.isModalOpen,
    required this.onRetry,
  });

  final MobileScannerController controller;
  final AsyncValue<FoodProduct?> scannerState;
  final bool isModalOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final barcodeValue = capture.barcodes.firstOrNull?.rawValue;
            if (barcodeValue != null && !isModalOpen) {
              ref.read(scannerNotifierProvider.notifier).fetchFood(barcodeValue);
            }
          },
        ),
        const ScannerOverlay(),
        if (scannerState.isLoading)
          const LoadingView()
        else if (scannerState.hasError)
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: ScannerErrorView(
              error: scannerState.error as ScannerError,
              onRetry: onRetry,
            ),
          ),
        if (kDebugMode)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (!ref.read(scannerNotifierProvider.notifier).canProcessBarcode('5449000000996')) {
                    return;
                  }
                  controller.stop();
                  ref.read(scannerNotifierProvider.notifier).fetchFood('5449000000996');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('🧪 Test Barkodu Tara'),
              ),
            ),
          ),
      ],
    );
  }
}
