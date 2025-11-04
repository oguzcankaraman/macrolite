import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme.g.dart';

@riverpod
ThemeData appTheme(Ref ref) {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.light),
    // Gelecekte AppBar, Button gibi tüm widget'ların stillerini
    // buradan merkezi olarak yöneteceğiz.
  );
}