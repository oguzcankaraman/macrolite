import 'package:hive/hive.dart';
import 'package:macrolite/core/domain/gender.dart';
import 'package:macrolite/core/domain/activity_level.dart';
import 'package:macrolite/core/domain/goal.dart';

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
  @HiveField(4)
  final double currentWeight;
  @HiveField(5)
  final double height; // in cm
  @HiveField(6)
  final int age;
  @HiveField(7)
  final Gender gender;
  @HiveField(8)
  final ActivityLevel activityLevel;
  @HiveField(9)
  final Goal goal;

  const UserProfile({
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.currentWeight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
  });

  factory UserProfile.defaults() {
    return const UserProfile(
      targetCalories: 2500,
      targetProtein: 150,
      targetCarbs: 250,
      targetFat: 80,
      currentWeight: 70,
      height: 170,
      age: 25,
      gender: Gender.male,
      activityLevel: ActivityLevel.moderate,
      goal: Goal.maintain,
    );
  }

  UserProfile copyWith({
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    double? currentWeight,
    double? height,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    Goal? goal,
  }) {
    return UserProfile(
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      currentWeight: currentWeight ?? this.currentWeight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  // Calculate BMI
  double get bmi => currentWeight / ((height / 100) * (height / 100));

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
