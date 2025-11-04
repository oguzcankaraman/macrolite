import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_found_view.dart';
import '../widgets/scanner_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    ref.listenManual<AsyncValue<FoodProduct?>>(scannerNotifierProvider, (previous, next) {
      if (previous is AsyncLoading && next is AsyncData) {
        final product = next.value;
        if (product != null) {
          _showProductFoundModal(context, ref, product);
        }
      }
      if (next is AsyncError) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Hata: ${next.error.toString()}')));
          _cameraController.start();
        }
      }
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // GÜNCELLEME: Metodun imzası, ona ne vermemiz gerektiğini gösteriyor.
  Future<void> _showProductFoundModal(BuildContext context, WidgetRef ref, FoodProduct product) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (_, scrollController) => ProductFoundView(
          product: product,
          scrollController: scrollController,
        ),
      ),
    );
    ref.read(scannerNotifierProvider.notifier).resetState();
    _cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Barkod Tara'),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (scannerState.isLoading) return;
              _cameraController.stop();
              final barcodeValue = capture.barcodes.firstOrNull?.rawValue;
              if (barcodeValue != null) {
                ref.read(scannerNotifierProvider.notifier).fetchFood(barcodeValue);
              }
            },
          ),
          const ScannerOverlay(),
          if (kDebugMode)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (scannerState.isLoading) return;
                    _cameraController.stop();
                    ref.read(scannerNotifierProvider.notifier).fetchFood('5449000000996');
                  },
                  child: const Text('Test Barkodu Tara'),
                ),
              ),
            ),
          if (scannerState.isLoading) const LoadingView(),
        ],
      ),
    );
  }
}