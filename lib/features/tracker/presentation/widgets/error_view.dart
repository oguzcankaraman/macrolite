import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Hata: $error',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),

      ),
    );
  }
}