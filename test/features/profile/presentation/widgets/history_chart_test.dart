import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/domain/daily_macro_summary.dart';
import 'package:macrolite/features/profile/presentation/widgets/history_chart.dart';
import 'package:macrolite/features/tracker/application/daily_summaries_provider.dart';

void main() {
  group('HistoryChart Widget Tests', () {
    testWidgets('renders chart with data', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 6));

      final testSummaries = List.generate(
        7,
        (index) => DailyMacroSummary(
          date: start.add(Duration(days: index)),
          calories: 1800 + (index * 100).toDouble(),
          protein: 150,
          carbs: 200,
          fat: 60,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailySummariesProvider(
              start: start,
              end: today,
            ).overrideWith((ref) async => testSummaries),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryChart())),
        ),
      );

      // Wait for chart to render
      await tester.pumpAndSettle();

      // Chart should be visible (AspectRatio widget contains the chart)
      expect(find.byType(AspectRatio), findsOneWidget);

      // No loading indicator or error message should be visible
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('handles empty data gracefully', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 6));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailySummariesProvider(
              start: start,
              end: today,
            ).overrideWith((ref) async => <DailyMacroSummary>[]),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryChart())),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "No data available" message
      expect(find.text('No data available'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('handles error state', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 6));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailySummariesProvider(
              start: start,
              end: today,
            ).overrideWith((ref) async => throw Exception('Test error')),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryChart())),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders with partial data', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(const Duration(days: 6));

      // Only 3 days of data instead of 7
      final testSummaries = List.generate(
        3,
        (index) => DailyMacroSummary(
          date: start.add(Duration(days: index)),
          calories: 2000,
          protein: 150,
          carbs: 200,
          fat: 60,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailySummariesProvider(
              start: start,
              end: today,
            ).overrideWith((ref) async => testSummaries),
          ],
          child: const MaterialApp(home: Scaffold(body: HistoryChart())),
        ),
      );

      await tester.pumpAndSettle();

      // Chart should still render with partial data
      expect(find.byType(AspectRatio), findsOneWidget);
      expect(find.text('No data available'), findsNothing);
    });
  });
}
