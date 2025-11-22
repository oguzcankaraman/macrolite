import 'package:macrolite/core/data/profile_repository.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/core/domain/macro_data.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';
import 'package:macrolite/features/tracker/application/daily_summaries_provider.dart';
import 'date_notifier.dart';
import 'tracker_state.dart';

part 'tracker_notifier.g.dart';

enum MacroKind {
  calorie('Kalori'),
  protein('Protein'),
  carbs('Karbonhidrat'),
  fat('Yağ');

  final String label;
  const MacroKind(this.label);

  static MacroKind fromLabel(String label) {
    return MacroKind.values.firstWhere((kind) => kind.label == label);
  }
}

@riverpod
class TrackerNotifier extends _$TrackerNotifier {
  @override
  Future<TrackerState> build() async {
    final selectedDate = ref.watch(selectedDateProvider);
    final repository = ref.watch(trackerRepositoryProvider);
    final profileRepository = await ref.watch(profileRepositoryProvider.future);
    await ref.watch(profileNotifierProvider.future);

    final meals = await repository.getMeals(selectedDate);

    final currentMacros = getCurrentMacros(profileRepository);
    final summaryData = _calculateSummaryData(meals, currentMacros);

    return TrackerState(summaryData: summaryData, meals: meals);
  }

  Map<String, double> getCurrentMacros(ProfileRepository profileRepo) {
    final user = profileRepo.getProfile();

    return {
      'calorieTarget': user.targetCalories,
      'proteinTarget': user.targetProtein,
      'carbTarget': user.targetCarbs,
      'fatTarget': user.targetFat,
    };
  }

  List<MacroData> _createEmptyMacroData(Map<String, double> targets) {
    return [
      MacroData(
        label: MacroKind.calorie.label,
        currentValue: 0,
        targetValue: targets['calorieTarget']!,
      ),
      MacroData(
        label: MacroKind.protein.label,
        currentValue: 0,
        targetValue: targets['proteinTarget']!,
      ),
      MacroData(
        label: MacroKind.carbs.label,
        currentValue: 0,
        targetValue: targets['carbTarget']!,
      ),
      MacroData(
        label: MacroKind.fat.label,
        currentValue: 0,
        targetValue: targets['fatTarget']!,
      ),
    ];
  }

  List<MacroData> _calculateSummaryData(
    List<Meal> meals,
    Map<String, double> currentMacros,
  ) {
    final allFoods = meals.expand((meal) => meal.loggedFoods).toList();

    if (allFoods.isEmpty) {
      return _createEmptyMacroData(currentMacros);
    }

    final totalCalories = allFoods.fold<double>(
      0,
      (sum, food) => sum + food.calories,
    );
    final totalProtein = allFoods.fold<double>(
      0,
      (sum, food) => sum + food.protein,
    );
    final totalCarbs = allFoods.fold<double>(
      0,
      (sum, food) => sum + food.carbs,
    );
    final totalFat = allFoods.fold<double>(0, (sum, food) => sum + food.fat);

    return [
      MacroData(
        label: MacroKind.calorie.label,
        currentValue: totalCalories,
        targetValue: currentMacros['calorieTarget']!,
      ),
      MacroData(
        label: MacroKind.protein.label,
        currentValue: totalProtein,
        targetValue: currentMacros['proteinTarget']!,
      ),
      MacroData(
        label: MacroKind.carbs.label,
        currentValue: totalCarbs,
        targetValue: currentMacros['carbTarget']!,
      ),
      MacroData(
        label: MacroKind.fat.label,
        currentValue: totalFat,
        targetValue: currentMacros['fatTarget']!,
      ),
    ];
  }

  Future<void> addFoodToMeal(String mealName, LoggedFood newFood) async {
    final repository = ref.read(trackerRepositoryProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final userProfileRepo = await ref.read(profileRepositoryProvider.future);

    final current = state.value;
    if (current == null) return;

    final currentState = state.value!;
    final currentMeals = List<Meal>.from(currentState.meals);
    final mealIndex = currentMeals.indexWhere((meal) => meal.name == mealName);

    if (mealIndex != -1) {
      final updatedFoods = List<LoggedFood>.from(
        currentMeals[mealIndex].loggedFoods,
      )..add(newFood);
      currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(
        loggedFoods: updatedFoods,
      );
    } else {
      currentMeals.add(Meal(name: mealName, loggedFoods: [newFood]));
    }

    final currentMacros = getCurrentMacros(userProfileRepo);
    final newSummaryData = _calculateSummaryData(currentMeals, currentMacros);

    await repository.saveMeals(selectedDate, currentMeals);

    // Invalidate daily summaries so profile charts update immediately
    ref.invalidate(dailySummariesProvider);

    state = AsyncData(
      currentState.copyWith(summaryData: newSummaryData, meals: currentMeals),
    );
  }

  Future<void> removeFood(String mealName, LoggedFood foodToRemove) async {
    final repository = ref.read(trackerRepositoryProvider);
    final selectedDate = ref.read(selectedDateProvider);
    final userProfileRepo = await ref.read(profileRepositoryProvider.future);

    final current = state.value;
    if (current == null) return;

    final currentState = state.value!;
    final currentMeals = List<Meal>.from(currentState.meals);

    final mealIndex = currentMeals.indexWhere((meal) => meal.name == mealName);

    if (mealIndex != -1) {
      final updatedFoods = currentMeals[mealIndex].loggedFoods
          .where((food) => food != foodToRemove)
          .toList();

      if (updatedFoods.isEmpty) {
        currentMeals.removeAt(mealIndex);
      } else {
        currentMeals[mealIndex] = currentMeals[mealIndex].copyWith(
          loggedFoods: updatedFoods,
        );
      }

      final currentMacros = getCurrentMacros(userProfileRepo);
      final newSummaryData = _calculateSummaryData(currentMeals, currentMacros);

      await repository.saveMeals(selectedDate, currentMeals);

      // Invalidate daily summaries so profile charts update immediately
      ref.invalidate(dailySummariesProvider);

      state = AsyncData(
        currentState.copyWith(summaryData: newSummaryData, meals: currentMeals),
      );
    }
  }
}
