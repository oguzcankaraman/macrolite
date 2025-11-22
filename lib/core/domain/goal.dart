import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 8)
enum Goal {
  @HiveField(0)
  loseWeight,

  @HiveField(1)
  maintain,

  @HiveField(2)
  gainMuscle;

  String get label {
    switch (this) {
      case Goal.loseWeight:
        return 'Kilo Ver';
      case Goal.maintain:
        return 'Kilonu Koru';
      case Goal.gainMuscle:
        return 'Kas Kazan';
    }
  }

  String get description {
    switch (this) {
      case Goal.loseWeight:
        return 'Sağlıklı bir şekilde kilo vermek';
      case Goal.maintain:
        return 'Mevcut kilonu korumak';
      case Goal.gainMuscle:
        return 'Kas kütlesi artırmak';
    }
  }

  int get calorieAdjustment {
    switch (this) {
      case Goal.loseWeight:
        return -500; // 0.5 kg/week loss
      case Goal.maintain:
        return 0;
      case Goal.gainMuscle:
        return 500; // 0.5 kg/week gain
    }
  }
}
