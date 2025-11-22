import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/data/profile_repository.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/features/profile/profile_notifier.dart';
import 'package:macrolite/features/tracker/presentation/screens/tracker_screen.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

// Mocks
class FakeTrackerRepository implements TrackerRepository {
  @override
  Future<List<Meal>> getMeals(DateTime date) async => [];
  @override
  Future<void> saveMeals(DateTime date, List<Meal> meals) async {}
  @override
  Future<List<Meal>> getMealsForDate(DateTime date) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  testWidgets('TrackerScreen updates when Profile targets change', (
    tester,
  ) async {
    final fakeProfileRepo = FakeProfileRepository();
    final fakeTrackerRepo = FakeTrackerRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackerRepositoryProvider.overrideWithValue(fakeTrackerRepo),
          profileRepositoryProvider.overrideWith((ref) => fakeProfileRepo),
        ],
        child: const MaterialApp(home: TrackerScreen()),
      ),
    );

    // Initial load
    await tester.pump();
    await tester.pump();

    // Check initial calorie target (default 2500, formatted as 2.500 in Turkish)
    expect(find.textContaining('2.500'), findsOneWidget);

    // Update Profile
    // We can't easily access the notifier to update it via UI here since we are on TrackerScreen.
    // But we can update the repository directly and trigger a refresh?
    // Or we can use a container to read the notifier.

    // Actually, TrackerNotifier watches profileRepositoryProvider.future.
    // If we update the repository, we need to notify listeners?
    // The real ProfileRepository uses Hive, and Riverpod might not watch Hive box changes automatically unless we setup a stream.
    // But ProfileNotifier updates the state AND saves to repo.
    // TrackerNotifier watches ProfileRepository... wait.

    // Let's check TrackerNotifier.
    // final profileRepository = await ref.watch(profileRepositoryProvider.future);
    // await ref.watch(profileNotifierProvider.future);

    // It watches profileNotifierProvider!
    // So if ProfileNotifier updates, TrackerNotifier should update.

    // So let's update ProfileNotifier.
    final element = tester.element(find.byType(TrackerScreen));
    final container = ProviderScope.containerOf(element);

    final newProfile = UserProfile.defaults().copyWith(targetCalories: 3000);
    await container
        .read(profileNotifierProvider.notifier)
        .updateProfile(newProfile);

    await tester.pumpAndSettle();

    // Check new calorie target (3000, formatted as 3.000 in Turkish)
    expect(find.textContaining('3.000'), findsOneWidget);
  });
}
