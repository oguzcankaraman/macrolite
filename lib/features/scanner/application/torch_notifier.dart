import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'torch_notifier.g.dart';

@riverpod
class TorchNotifier extends _$TorchNotifier {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }

  void disable() {
    state = false;
  }
}
