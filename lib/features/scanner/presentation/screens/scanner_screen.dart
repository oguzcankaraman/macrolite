import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:macrolite/features/scanner/application/camera_permission_notifier.dart';
import 'package:macrolite/features/scanner/application/torch_notifier.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/presentation/widgets/food_quantity_sheet.dart';
import 'package:uuid/uuid.dart';
import '../widgets/scanner_view.dart';
import '../widgets/camera_permission_widget.dart';
import '../widgets/torch_button.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupListener();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumed();
        break;
      case AppLifecycleState.paused:
        _handlePaused();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleResumed() async {
    ref.invalidate(cameraPermissionNotifierProvider);

    if (!_isModalOpen) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted && !_cameraController.value.isRunning) {
        await _cameraController.start();
      }
    }
  }

  Future<void> _handlePaused() async {
    ref.read(scannerNotifierProvider.notifier).clearBarcodeCache();

    if (ref.read(torchNotifierProvider)) {
      await _cameraController.toggleTorch();
      ref.read(torchNotifierProvider.notifier).disable();
    }

    if (_cameraController.value.isRunning) {
      await _cameraController.stop();
    }
  }

  void _setupListener() {
    ref.listenManual<AsyncValue<FoodProduct?>>(scannerNotifierProvider, (
      previous,
      next,
    ) {
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

  Future<void> _showProductFoundModal(
    BuildContext context,
    WidgetRef ref,
    FoodProduct product,
  ) async {
    _isModalOpen = true;
    await _cameraController.stop();

    if (ref.read(torchNotifierProvider)) {
      await _cameraController.toggleTorch();
      ref.read(torchNotifierProvider.notifier).disable();
    }

    if (!mounted) return;

    // Convert FoodProduct to FoodItem
    final foodItem = FoodItem(
      id: const Uuid().v4(),
      name: product.productName,
      calories: product.caloriesPer100g,
      protein: product.proteinPer100g,
      carbs: product.carbsPer100g,
      fat: product.fatPer100g,
      unit: 'gram',
      baseAmount: 100.0,
      servingSizeG: product.servingQuantity > 0
          ? product.servingQuantity
          : null,
      servingUnit: _parseServingUnit(product.servingSize),
    );

    final result = await showModalBottomSheet<LoggedFood>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: FoodQuantitySheet(
            food: foodItem,
            mealName: null, // User selects meal
          ),
        ),
      ),
    );

    _isModalOpen = false;

    if (mounted) {
      ref.read(scannerNotifierProvider.notifier).resetState();

      if (result != null) {
        // Food added, return to tracker
        Navigator.pop(context);
      } else {
        // Cancelled, restart scanner
        _restartScanner();
      }
    }
  }

  String? _parseServingUnit(String? servingSize) {
    if (servingSize == null) return null;
    final s = servingSize.toLowerCase();
    if (s.contains('ml') || s.contains('milliliter') || s.contains(' l '))
      return 'Ml';
    if (s.contains('biscuit') ||
        s.contains('cookie') ||
        s.contains('adet') ||
        s.contains('piece') ||
        s.contains('egg'))
      return 'Adet';
    if (s.contains('slice') || s.contains('dilim')) return 'Dilim';
    if (s.contains('bar') || s.contains('paket') || s.contains('pack'))
      return 'Paket';
    if (s.contains('cup') || s.contains('bardak')) return 'Bardak';
    if (s.contains('tbsp') || s.contains('kaşık')) return 'Kaşık';
    if (s.contains('portion') || s.contains('porsiyon')) return 'Porsiyon';
    return null;
  }

  void _restartScanner() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isModalOpen) {
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
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Barkod Tara', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        actions: [
          if (permissionState.valueOrNull?.isGranted == true)
            TorchButton(controller: _cameraController),
        ],
      ),
      body: permissionState.when(
        data: (status) {
          if (status.isGranted) {
            return ScannerView(
              controller: _cameraController,
              scannerState: scannerState,
              isModalOpen: _isModalOpen,
              onRetry: _restartScanner,
            );
          } else {
            return const CameraPermissionWidget();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const CameraPermissionWidget(),
      ),
    );
  }
}
