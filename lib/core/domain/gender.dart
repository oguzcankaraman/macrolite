import 'package:hive/hive.dart';

part 'gender.g.dart';

@HiveType(typeId: 6)
enum Gender {
  @HiveField(0)
  male,

  @HiveField(1)
  female,

  @HiveField(2)
  other;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kadın';
      case Gender.other:
        return 'Diğer';
    }
  }
}
