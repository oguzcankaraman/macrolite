import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/core/navigation/app_router_provider.dart';
import 'package:macrolite/core/theme/app_theme.dart';
import 'package:macrolite/core/domain/food_unit.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:intl/date_symbol_data_local.dart'; // Bu import'u ekleyin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  Hive.registerAdapter(FoodUnitAdapter());
  Hive.registerAdapter(LoggedFoodAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(UserProfileAdapter());

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