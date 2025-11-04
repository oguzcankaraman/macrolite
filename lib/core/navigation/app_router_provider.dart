import 'package:go_router/go_router.dart';
import 'package:macrolite/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:macrolite/features/tracker/presentation/screens/add_food_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/tracker/presentation/screens/tracker_screen.dart';

part 'app_router_provider.g.dart';

class AppRoute {
  static const String tracker = "/";
  static const String addFood = "/add-food";
  static const String scanner = "/scanner";
}

@riverpod
class AppRouter extends _$AppRouter {
  @override
  GoRouter build() {
    return GoRouter(
      initialLocation: AppRoute.tracker,

      routes: [
        GoRoute(
          path: AppRoute.tracker,
          builder: (context, state) => const TrackerScreen(),
        ),
        GoRoute(
          path: AppRoute.addFood,
          builder: (context, state) => const AddFoodScreen(),
        ),
        GoRoute(
          path: AppRoute.scanner,
          builder: (context, state) => const ScannerScreen(),
        ),
      ],
    );
  }
}