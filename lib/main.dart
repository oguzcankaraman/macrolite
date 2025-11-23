import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/core/navigation/app_router_provider.dart';
import 'package:macrolite/core/theme/app_theme.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/features/tracker/domain/recipe.dart';
import 'package:macrolite/core/domain/gender.dart';
import 'package:macrolite/core/domain/activity_level.dart';
import 'package:macrolite/core/domain/goal.dart';
import 'package:intl/date_symbol_data_local.dart'; // Bu import'u ekleyin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  Hive.registerAdapter(FoodUnitAdapter());
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(LoggedFoodAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(GenderAdapter());
  Hive.registerAdapter(ActivityLevelAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(RecipeAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<FoodItem>('food_library');
  await Hive.openBox<Recipe>('recipes');

  // Migration: Delete old profile box if it exists with old format
  // This prevents crash when trying to deserialize incompatible data
  try {
    final boxExists = await Hive.boxExists('user_profile');
    if (boxExists) {
      // Check if we need migration by trying to read the raw data
      // If this is old format, delete the box entirely
      try {
        // Try to open and immediately close to test compatibility
        final testBox = await Hive.openBox<UserProfile>('user_profile');
        final profile = testBox.get(0);
        await testBox.close();

        // If profile exists but is missing new fields, it's old data
        if (profile != null) {
          try {
            // Test if new fields exist
            final _ = profile.age;
          } catch (e) {
            // Old format - delete the box
            debugPrint('Old profile format detected, deleting box');
            await Hive.deleteBoxFromDisk('user_profile');
          }
        }
      } catch (e) {
        // Any error means incompatible data - delete the box
        debugPrint('Migration error detected: $e');
        debugPrint('Deleting incompatible profile box');
        await Hive.deleteBoxFromDisk('user_profile');
      }
    }
  } catch (e) {
    debugPrint('Migration check failed: $e');
  }

  runApp(const ProviderScope(child: MacroLiteApp()));
}

class MacroLiteApp extends ConsumerWidget {
  const MacroLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'MacroLite',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}
