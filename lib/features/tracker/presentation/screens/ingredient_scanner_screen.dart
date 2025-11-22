import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:macrolite/core/domain/food_product.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';
import 'package:macrolite/features/scanner/application/camera_permission_notifier.dart';
import 'package:macrolite/features/scanner/application/torch_notifier.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:macrolite/features/scanner/presentation/widgets/scanner_view.dart';
import 'package:macrolite/features/scanner/presentation/widgets/camera_permission_widget.dart';
import 'package:macrolite/features/scanner/presentation/widgets/torch_button.dart';

class IngredientScannerScreen extends ConsumerStatefulWidget {
  const IngredientScannerScreen({super.key});

  @override
  ConsumerState<IngredientScannerScreen> createState() =>
      _IngredientScannerScreenState();
}

class _IngredientScannerScreenState
    extends ConsumerState<IngredientScannerScreen>
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
        _showIngredientConfirmSheet(context, ref, next.value!);
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

  Future<void> _showIngredientConfirmSheet(
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

    final result = await showModalBottomSheet<LoggedFood>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _IngredientConfirmSheet(product: product),
    );

    _isModalOpen = false;

    if (mounted) {
      ref.read(scannerNotifierProvider.notifier).resetState();

      if (result != null) {
        // Return the ingredient to the calling screen
        context.pop(result);
      } else {
        // User cancelled, restart scanner
        _restartScanner();
      }
    }
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Malzeme Tara',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        actions: [
          if (permissionState.valueOrNull == PermissionStatus.granted)
            TorchButton(controller: _cameraController),
        ],
      ),
      body: permissionState.when(
        data: (status) {
          if (status == PermissionStatus.granted) {
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

class _IngredientConfirmSheet extends StatefulWidget {
  final FoodProduct product;

  const _IngredientConfirmSheet({required this.product});

  @override
  State<_IngredientConfirmSheet> createState() =>
      _IngredientConfirmSheetState();
}

class _IngredientConfirmSheetState extends State<_IngredientConfirmSheet> {
  final _quantityController = TextEditingController(text: '100');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _confirm() {
    final quantity = double.tryParse(_quantityController.text) ?? 100;

    final ingredient = LoggedFood(
      name: widget.product.productName,
      quantity: quantity,
      unit: FoodUnit.gram,
      calories: widget.product.caloriesPer100g.round(),
      protein: widget.product.proteinPer100g,
      carbs: widget.product.carbsPer100g,
      fat: widget.product.fatPer100g,
    );

    Navigator.pop(context, ingredient);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.product.productName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '100g başına: ${widget.product.caloriesPer100g.round()} kcal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Miktar (g)',
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroDisplay(
                label: 'Protein',
                value: '${widget.product.proteinPer100g.toStringAsFixed(1)}',
                unit: 'g',
              ),
              _MacroDisplay(
                label: 'Karb',
                value: '${widget.product.carbsPer100g.toStringAsFixed(1)}',
                unit: 'g',
              ),
              _MacroDisplay(
                label: 'Yağ',
                value: '${widget.product.fatPer100g.toStringAsFixed(1)}',
                unit: 'g',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Ekle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MacroDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroDisplay({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          '$value $unit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
