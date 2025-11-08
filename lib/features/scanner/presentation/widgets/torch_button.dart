import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:macrolite/features/scanner/application/torch_notifier.dart';

class TorchButton extends ConsumerWidget {
  const TorchButton({
    super.key,
    required this.controller,
  });

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTorchEnabled = ref.watch(torchNotifierProvider);

    return IconButton(
      icon: Icon(
        isTorchEnabled ? Icons.flash_on : Icons.flash_off,
        color: Colors.white,
      ),
      onPressed: () async {
        try {
          await controller.toggleTorch();
          ref.read(torchNotifierProvider.notifier).toggle();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El feneri kullanılamıyor')),
            );
          }
        }
      },
    );
  }
}
