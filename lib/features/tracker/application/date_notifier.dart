// lib/features/tracker/application/date_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_notifier.g.dart';

// Bu Notifier, kullanıcının o an seçtiği tarihi saklayacak.
// Başlangıçta her zaman "bugün"ü gösterir.
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    // Başlangıç durumu: şu anki tarih (saat, dakika olmadan)
    return _dateOnly(DateTime.now());
  }

  // Tarihi bir gün ileri alır
  void nextDay() {
    state = _dateOnly(state.add(const Duration(days: 1)));
  }

  // Tarihi bir gün geri alır
  void previousDay() {
    state = _dateOnly(state.subtract(const Duration(days: 1)));
  }

  // Tarihi bugüne sıfırlar
  void setToday() {
    state = _dateOnly(DateTime.now());
  }

  // Saati, dakikayı ve saniyeyi sıfırlayan bir yardımcı metot
  DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }
}