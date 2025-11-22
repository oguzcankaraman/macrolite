import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/core/domain/gender.dart';
import 'package:macrolite/core/domain/activity_level.dart';
import 'package:macrolite/core/domain/goal.dart';

class MacroCalculator {
  /// Calculate Basal Metabolic Rate using Mifflin-St Jeor Equation
  /// Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
  /// Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required Gender gender,
  }) {
    final baseCalculation = (10 * weight) + (6.25 * height) - (5 * age);

    switch (gender) {
      case Gender.male:
        return baseCalculation + 5;
      case Gender.female:
        return baseCalculation - 161;
      case Gender.other:
        // Average of male and female
        return baseCalculation - 78;
    }
  }

  /// Calculate Total Daily Energy Expenditure
  /// TDEE = BMR × Activity Level Multiplier
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Calculate target calories based on goal
  static int calculateTargetCalories({
    required double tdee,
    required Goal goal,
  }) {
    return (tdee + goal.calorieAdjustment).round();
  }

  /// Calculate protein target (1.6-2.2g per kg, we'll use 2g)
  static int calculateProteinTarget(double weight) {
    return (weight * 2).round();
  }

  /// Calculate fat target (25% of calories)
  static int calculateFatTarget(int targetCalories) {
    // Fat has 9 calories per gram
    return ((targetCalories * 0.25) / 9).round();
  }

  /// Calculate carbs target (remaining calories)
  static int calculateCarbsTarget({
    required int targetCalories,
    required int proteinGrams,
    required int fatGrams,
  }) {
    // Protein and carbs have 4 calories per gram, fat has 9
    final proteinCalories = proteinGrams * 4;
    final fatCalories = fatGrams * 9;
    final remainingCalories = targetCalories - proteinCalories - fatCalories;

    // Carbs have 4 calories per gram
    return (remainingCalories / 4).round();
  }

  /// Calculate complete macros for a user
  static Map<String, int> calculateMacros({
    required double weight,
    required double height,
    required int age,
    required Gender gender,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);

    final targetCalories = calculateTargetCalories(tdee: tdee, goal: goal);

    final protein = calculateProteinTarget(weight);
    final fat = calculateFatTarget(targetCalories);
    final carbs = calculateCarbsTarget(
      targetCalories: targetCalories,
      proteinGrams: protein,
      fatGrams: fat,
    );

    return {
      'calories': targetCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Calculate macros from UserProfile
  static Map<String, int> calculateMacrosFromProfile(UserProfile profile) {
    return calculateMacros(
      weight: profile.currentWeight,
      height: profile.height,
      age: profile.age,
      gender: profile.gender,
      activityLevel: profile.activityLevel,
      goal: profile.goal,
    );
  }

  /// Apply calculated macros to a UserProfile
  static UserProfile applyCalculatedMacros(UserProfile profile) {
    final macros = calculateMacrosFromProfile(profile);

    return profile.copyWith(
      targetCalories: macros['calories']!.toDouble(),
      targetProtein: macros['protein']!.toDouble(),
      targetCarbs: macros['carbs']!.toDouble(),
      targetFat: macros['fat']!.toDouble(),
    );
  }
}
