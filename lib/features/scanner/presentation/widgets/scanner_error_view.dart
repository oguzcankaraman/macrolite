import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/scanner/domain/scanner_error.dart';
import 'package:macrolite/features/scanner/application/scanner_notifier.dart';

class ScannerErrorView extends ConsumerWidget {
  const ScannerErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final ScannerError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(),
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.getMessage(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(scannerNotifierProvider.notifier).resetState();
                  onRetry();
                },
                child: const Text(
                  'İPTAL',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(scannerNotifierProvider.notifier).retryLastBarcode();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('YENİDEN DENE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    return switch (error) {
      ProductNotFoundError() => Icons.search_off,
      NetworkError() => Icons.wifi_off,
      UnknownError() => Icons.error_outline,
    };
  }
}
