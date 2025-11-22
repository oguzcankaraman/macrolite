import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrolite/core/domain/macro_data.dart';
import 'package:macrolite/features/tracker/presentation/widgets/daily_progress_card.dart';

void main() {
  testWidgets('DailyProgressCard displays correct values and progress', (
    WidgetTester tester,
  ) async {
    final summaryData = [
      const MacroData(label: 'Kalori', currentValue: 1500, targetValue: 2000),
      const MacroData(label: 'Protein', currentValue: 100, targetValue: 150),
      const MacroData(
        label: 'Karbonhidrat',
        currentValue: 150,
        targetValue: 200,
      ),
      const MacroData(label: 'Yağ', currentValue: 50, targetValue: 70),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DailyProgressCard(summaryData: summaryData)),
      ),
    );
    await tester.pumpAndSettle();

    // Check Calories
    expect(find.text('Calories'), findsOneWidget);
    expect(find.textContaining('1500 / 2000'), findsOneWidget);
    expect(find.textContaining('500 left'), findsOneWidget);

    // Check Macros
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.textContaining('/150g'), findsOneWidget);

    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.textContaining('/200g'), findsOneWidget);

    expect(find.text('Fat'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.textContaining('/70g'), findsOneWidget);
  });

  testWidgets('DailyProgressCard handles over consumption correctly', (
    WidgetTester tester,
  ) async {
    final summaryData = [
      const MacroData(label: 'Kalori', currentValue: 2500, targetValue: 2000),
      const MacroData(label: 'Protein', currentValue: 160, targetValue: 150),
      const MacroData(
        label: 'Karbonhidrat',
        currentValue: 210,
        targetValue: 200,
      ),
      const MacroData(label: 'Yağ', currentValue: 80, targetValue: 70),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DailyProgressCard(summaryData: summaryData)),
      ),
    );
    await tester.pumpAndSettle();

    // Check Calories Over
    expect(find.text('500 over'), findsOneWidget);

    // Verify red color for over consumption (requires finding the Text widget and checking style)
    final overTextFinder = find.text('500 over');
    final Text overText = tester.widget(overTextFinder);
    expect(overText.style?.color, Colors.red);
  });
}
