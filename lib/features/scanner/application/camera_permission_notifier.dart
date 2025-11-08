import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_permission_notifier.g.dart';

@riverpod
class CameraPermissionNotifier extends _$CameraPermissionNotifier {
  @override
  FutureOr<PermissionStatus> build() async {
    return await Permission.camera.status;
  }

  Future<void> requestPermission() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await Permission.camera.request();
    });
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
