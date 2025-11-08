import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:macrolite/features/scanner/application/camera_permission_notifier.dart';
import 'package:macrolite/features/scanner/application/torch_notifier.dart';
import 'package:macrolite/features/scanner/domain/scanner_error.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_found_view.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/camera_permission_widget.dart';
import '../widgets/torch_button.dart';
import '../widgets/scanner_error_view.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController _cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupListener();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(cameraPermissionNotifierProvider);
    } else if (state == AppLifecycleState.paused) {
      ref.read(scannerNotifierProvider.notifier).clearBarcodeCache();
      if (ref.read(torchNotifierProvider)) {
        _cameraController.toggleTorch();
        ref.read(torchNotifierProvider.notifier).disable();
      }
    }
  }

  void _setupListener() {
    ref.listenManual<AsyncValue<FoodProduct?>>(scannerNotifierProvider, (previous, next) {
      // Sadece başarılı bir ürün bulunduğunda modal aç
      if (next is AsyncData && next.value != null) {
        _showProductFoundModal(context, ref, next.value!);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ref.read(torchNotifierProvider)) {
      _cameraController.toggleTorch();
    }
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _showProductFoundModal(BuildContext context, WidgetRef ref, FoodProduct product) async {
    await _cameraController.stop();

    if (ref.read(torchNotifierProvider)) {
      await _cameraController.toggleTorch();
      ref.read(torchNotifierProvider.notifier).disable();
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ProductFoundView(
          product: product,
          scrollController: scrollController,
        ),
      ),
    );

    if (mounted) {
      ref.read(scannerNotifierProvider.notifier).resetState();
      _restartScanner();
    }
  }

  void _restartScanner() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _cameraController.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);
    final permissionState = ref.watch(cameraPermissionNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Barkod Tara'),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        actions: [
          if (permissionState.valueOrNull?.isGranted == true)
            TorchButton(controller: _cameraController),
        ],
      ),
      body: permissionState.when(
        data: (status) {
          if (status.isGranted) {
            return _buildScannerView(scannerState);
          } else {
            return const CameraPermissionWidget();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const CameraPermissionWidget(),
      ),
    );
  }

  Widget _buildScannerView(AsyncValue<FoodProduct?> scannerState) {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: (capture) {
            final barcodeValue = capture.barcodes.firstOrNull?.rawValue;
            if (barcodeValue != null) {
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
              onRetry: _restartScanner,
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
                  _cameraController.stop();
                  ref.read(scannerNotifierProvider.notifier).fetchFood('5449000000996');
                },
                child: const Text('Test Barkodu Tara'),
              ),
            ),
          ),
      ],
    );
  }
}
