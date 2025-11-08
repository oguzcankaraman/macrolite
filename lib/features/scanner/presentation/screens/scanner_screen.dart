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
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(cameraPermissionNotifierProvider);
    } else if (state == AppLifecycleState.paused) {
      // Uygulama arka plana atıldığında cache'i temizle
      ref.read(scannerNotifierProvider.notifier).clearBarcodeCache();
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
          _restartScanner();
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
    // Modal açılırken kamerayı durdur
    await _cameraController.stop();

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

    // Modal kapandığında state'i sıfırla ve taramayı yeniden başlat
    if (mounted) {
      ref.read(scannerNotifierProvider.notifier).resetState();
      _restartScanner();
    }
  }

  void _restartScanner() {
    // Kısa bir gecikmeyle kamerayı yeniden başlat
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
              // Notifier'daki canProcessBarcode kontrolü devreye girecek
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
