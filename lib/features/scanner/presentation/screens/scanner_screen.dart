import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:macrolite/features/scanner/application/camera_permission_notifier.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/loading_view.dart';
import '../widgets/product_found_view.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/camera_permission_widget.dart';

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
    // Uygulama ön plana geldiğinde izin durumunu kontrol et
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(cameraPermissionNotifierProvider);
    }
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
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

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
    final permissionState = ref.watch(cameraPermissionNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Barkod Tara'),
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
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
    );
  }
}
