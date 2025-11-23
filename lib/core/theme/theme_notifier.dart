import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  static const _boxName = 'settings';
  static const _key = 'isDarkMode';

  void _loadTheme() {
    final box = Hive.box(_boxName);
    state = box.get(_key, defaultValue: false);
  }

  void toggle() {
    state = !state;
    final box = Hive.box(_boxName);
    box.put(_key, state);
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
