import 'package:flutter/material.dart';

class MacroInputField extends StatelessWidget {
  const MacroInputField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText),
        keyboardType: TextInputType.number,
        // Doğrulama mantığı, bu widget'ı çağıran ana formda kalmalı,
        // ancak basitlik için buraya da taşıyabiliriz. Şimdilik burada kalsın.
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen bir değer girin.';
          }
          if (double.tryParse(value) == null) {
            return 'Lütfen geçerli bir sayı girin.';
          }
          return null;
        },
      ),
    );
  }
}