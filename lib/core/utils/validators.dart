String? numericValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Lütfen bir değer girin.';
  }
  if (double.tryParse(value) == null) {
    return 'Lütfen geçerli bir sayı girin.';
  }
  return null;
}