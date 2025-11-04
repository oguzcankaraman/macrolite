import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile {
  @HiveField(0)
  final double targetCalories;
  @HiveField(1)
  final double targetProtein;
  @HiveField(2)
  final double targetCarbs;
  @HiveField(3)
  final double targetFat;

  const UserProfile({
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  factory UserProfile.defaults() {
    return const UserProfile(
      targetCalories: 2500,
      targetProtein: 150,
      targetCarbs: 250,
      targetFat: 80,
    );
  }
}