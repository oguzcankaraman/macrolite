import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/domain/daily_macro_summary.dart';
import 'package:macrolite/features/profile/presentation/screens/profile_screen.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';
import 'package:macrolite/core/data/profile_repository.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:hive/hive.dart';

class FakeTrackerRepository implements TrackerRepository {
  final List<DailyMacroSummary> summaries;

  FakeTrackerRepository(this.summaries);

  @override
  Future<List<DailyMacroSummary>> getDailySummaries({
    required DateTime start,
    required DateTime end,
  }) async {
    return summaries;
  }

  @override
  Future<List<Meal>> getMeals(DateTime date) async => [];

  @override
  Future<List<Meal>> getMealsForDate(DateTime date) async => [];

  @override
  Future<void> saveMeals(DateTime date, List<Meal> meals) async {}
}

class FakeProfileRepository implements ProfileRepository {
  UserProfile _profile = UserProfile.defaults();

  @override
  Box<UserProfile> get profileBox => throw UnimplementedError();

  @override
  UserProfile getProfile() {
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> resetProfile() async {
    _profile = UserProfile.defaults();
  }
}

void main() {
  testWidgets('ProfileScreen displays chart with data', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime.now();
    final summaries = [
      DailyMacroSummary(
        date: today,
        calories: 500,
        protein: 30,
        carbs: 50,
        fat: 20,
      ),
    ];
    final fakeProfileRepo = FakeProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackerRepositoryProvider.overrideWithValue(
            FakeTrackerRepository(summaries),
          ),
          profileRepositoryProvider.overrideWith((ref) => fakeProfileRepo),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    // Allow the provider to initialize and the future to complete
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Last 7 Days'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('ProfileScreen displays empty state message', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeProfileRepo = FakeProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackerRepositoryProvider.overrideWithValue(
            FakeTrackerRepository([]),
          ),
          profileRepositoryProvider.overrideWith((ref) => fakeProfileRepo),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('ProfileScreen displays settings and allows editing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime.now();
    final summaries = [
      DailyMacroSummary(date: today, calories: 0, protein: 0, carbs: 0, fat: 0),
    ];
    final fakeProfileRepo = FakeProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackerRepositoryProvider.overrideWithValue(
            FakeTrackerRepository(summaries),
          ),
          profileRepositoryProvider.overrideWith((ref) => fakeProfileRepo),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify initial values
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('70.0 kg'), findsOneWidget);
    expect(find.text('2500 kcal'), findsOneWidget);

    // Edit Weight
    await tester.tap(find.text('Current Weight'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Current Weight'), findsOneWidget);

    // Enter new weight
    await tester.enterText(find.byType(TextField), '75.0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify new weight is displayed
    expect(find.text('75.0 kg'), findsOneWidget);

    // Verify repository was updated
    expect(fakeProfileRepo.getProfile().currentWeight, 75.0);
  });
}
