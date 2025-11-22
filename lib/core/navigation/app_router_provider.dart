import 'package:go_router/go_router.dart';
import 'package:macrolite/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:macrolite/features/tracker/presentation/screens/add_food_screen.dart';
import 'package:macrolite/core/presentation/main_scaffold.dart';
import 'package:macrolite/features/profile/presentation/screens/profile_screen.dart';
import '../../features/tracker/presentation/screens/tracker_screen.dart';
import 'package:macrolite/features/onboarding/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router_provider.g.dart';

class AppRoute {
  static const String tracker = "/";
  static const String onboarding = "/onboarding";
  static const String addFood = "/add-food";
  static const String scanner = "/scanner";
  static const String history = "/history";
  static const String profile = "/profile";
}

@riverpod
class AppRouter extends _$AppRouter {
  @override
  GoRouter build() {
    return GoRouter(
      initialLocation: AppRoute.tracker,
      redirect: (context, state) async {
        // Don't redirect if already on onboarding
        if (state.matchedLocation == AppRoute.onboarding) {
          return null;
        }

        // Check if we need onboarding
        final container = ProviderScope.containerOf(context);
        final profileAsync = await container.read(
          profileNotifierProvider.future,
        );

        // If profile is at defaults, show onboarding
        final needsOnboarding =
            profileAsync.age == 25 &&
            profileAsync.currentWeight == 70 &&
            profileAsync.height == 170;

        if (needsOnboarding) {
          return AppRoute.onboarding;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoute.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.tracker,
                  builder: (context, state) => const TrackerScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoute.profile,
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
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
