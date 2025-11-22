import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macrolite/core/domain/macro_data.dart';
import 'package:macrolite/features/scanner/presentation/widgets/error_view.dart';
import 'package:macrolite/features/scanner/presentation/widgets/loading_view.dart';
import 'package:macrolite/features/tracker/presentation/widgets/add_food_fab.dart';
import '../../application/date_notifier.dart';
import '../../application/tracker_notifier.dart';
import '../../domain/meal.dart';
import '../widgets/meal_card.dart';
import '../widgets/daily_progress_card.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd('tr_TR').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerStateAsync = ref.watch(trackerNotifierProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final dateNotifier = ref.read(selectedDateProvider.notifier);
    final bool isToday = _isToday(selectedDate);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => dateNotifier.previousDay(),
        ),
        title: Text(_formatDate(selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => dateNotifier.nextDay(),
          ),
        ],
        bottom: isToday
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(30.0),
                child: TextButton(
                  onPressed: () => dateNotifier.setToday(),
                  child: const Text('Bugün\'e Dön'),
                ),
              ),
      ),
      body: trackerStateAsync.when(
        data: (trackerState) {
          final List<MacroData> summaryData = trackerState.summaryData;
          final List<Meal> meals = trackerState.meals;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DailyProgressCard(summaryData: summaryData),
                const SizedBox(height: 24),
                Expanded(
                  child: meals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  size: 64,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No meals logged yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to track your first meal',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: meals.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            return MealCard(meal: meal, isToday: isToday);
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(error: err.toString()),
      ),

      floatingActionButton: isToday ? const AddFoodFab() : null,
    );
  }
}
