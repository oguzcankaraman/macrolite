import 'package:hive/hive.dart';

part 'activity_level.g.dart';

@HiveType(typeId: 7)
enum ActivityLevel {
  @HiveField(0)
  sedentary,

  @HiveField(1)
  light,

  @HiveField(2)
  moderate,

  @HiveField(3)
  active,

  @HiveField(4)
  veryActive;

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Hareketsiz';
      case ActivityLevel.light:
        return 'Az Hareketli';
      case ActivityLevel.moderate:
        return 'Orta Hareketli';
      case ActivityLevel.active:
        return 'Aktif';
      case ActivityLevel.veryActive:
        return 'Çok Aktif';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Masabaşı işi, az hareket';
      case ActivityLevel.light:
        return 'Haftada 1-3 gün hafif egzersiz';
      case ActivityLevel.moderate:
        return 'Haftada 3-5 gün orta egzersiz';
      case ActivityLevel.active:
        return 'Haftada 6-7 gün yoğun egzersiz';
      case ActivityLevel.veryActive:
        return 'Günde 2 kez egzersiz veya fiziksel iş';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }
}
