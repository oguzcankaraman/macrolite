import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/domain/user_profile.dart';
import 'package:macrolite/features/profile/presentation/widgets/bmi_card.dart';
import 'package:macrolite/core/data/profile_repository.dart';
import 'package:macrolite/core/domain/gender.dart';
import 'package:macrolite/core/domain/activity_level.dart';
import 'package:macrolite/core/domain/goal.dart';
import 'package:hive/hive.dart';

// Mock ProfileRepository for testing
class MockProfileRepository extends ProfileRepository {
  MockProfileRepository(this.testProfile)
    : super(Hive.box<UserProfile>('test'));

  final UserProfile testProfile;

  @override
  UserProfile getProfile() {
    return testProfile;
  }
}

void main() {
  group('BmiCard Widget Tests', () {
    final testProfile = const UserProfile(
      targetCalories: 2000,
      targetProtein: 150,
      targetCarbs: 250,
      targetFat: 70,
      currentWeight: 75,
      height: 175,
      age: 30,
      gender: Gender.male,
      activityLevel: ActivityLevel.moderate,
      goal: Goal.maintain,
    );

    testWidgets('renders BMI value correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) async => MockProfileRepository(testProfile),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      await tester.pumpAndSettle();

      // Calculate expected BMI: 75 / (1.75 * 1.75) = 24.5
      final expectedBmi = (75 / (1.75 * 1.75)).toStringAsFixed(1);
      expect(find.text(expectedBmi), findsOneWidget);
    });

    testWidgets('shows correct category', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) async => MockProfileRepository(testProfile),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      await tester.pumpAndSettle();

      // BMI 24.5 should be "Normal"
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('tap gesture expands card', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) async => MockProfileRepository(testProfile),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      await tester.pumpAndSettle();

      // Initially expanded content should not be visible
      expect(find.text('Healthy Weight Range'), findsNothing);

      // Tap the card to expand
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Expanded content should now be visible
      expect(find.text('Healthy Weight Range'), findsOneWidget);
    });

    testWidgets('tap gesture collapses expanded card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) async => MockProfileRepository(testProfile),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      await tester.pumpAndSettle();

      // Expand the card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(find.text('Healthy Weight Range'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Expanded content should be hidden again
      expect(find.text('Healthy Weight Range'), findsNothing);
    });

    testWidgets('handles loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWith(
              (ref) async => throw Exception('Test error'),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: BmiCard())),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error'), findsOneWidget);
    });
  });
}
