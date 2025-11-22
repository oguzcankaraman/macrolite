import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/core/theme/theme_notifier.dart';

final appThemeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(themeNotifierProvider);
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
});
