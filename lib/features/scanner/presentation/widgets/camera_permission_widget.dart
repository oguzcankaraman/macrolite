import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:macrolite/features/scanner/application/camera_permission_notifier.dart';

class CameraPermissionWidget extends ConsumerWidget {
  const CameraPermissionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Kamera İzni Gerekli',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Barkod tarayabilmek için kamera erişimine izin vermeniz gerekiyor.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final status = await ref.read(cameraPermissionNotifierProvider.future);
                  if (status.isPermanentlyDenied) {
                    await ref.read(cameraPermissionNotifierProvider.notifier).openSettings();
                  } else {
                    await ref.read(cameraPermissionNotifierProvider.notifier).requestPermission();
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('İzin Ver'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
