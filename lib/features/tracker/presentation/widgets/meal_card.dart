import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macrolite/features/tracker/application/tracker_notifier.dart';
import 'package:macrolite/features/tracker/domain/meal.dart';
import 'package:macrolite/features/tracker/domain/logged_food.dart';

class MealCard extends ConsumerWidget {
  const MealCard({super.key, required this.meal, required this.isToday});

  final Meal meal;
  final bool isToday;

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    LoggedFood food,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yiyeceği Sil'),
          content: Text(
            '"${food.name}" adlı yiyeceği silmek istediğinizden emin misiniz?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ref
                    .read(trackerNotifierProvider.notifier)
                    .removeFood(meal.name, food);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCalories = meal.totalCalories;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getMealIcon(meal.name),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            meal.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '${totalCalories.toInt()} kcal',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: meal.loggedFoods.map((food) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${food.quantity} ${food.unit.label}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${food.calories.toInt()} kcal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.red[400],
                            onPressed: () => _showDeleteConfirmationDialog(
                              context,
                              ref,
                              food,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealName) {
    final name = mealName.toLowerCase();
    if (name.contains('kahvaltı') || name.contains('breakfast')) {
      return Icons.wb_sunny_outlined;
    } else if (name.contains('öğle') || name.contains('lunch')) {
      return Icons.wb_twilight;
    } else if (name.contains('akşam') || name.contains('dinner')) {
      return Icons.nights_stay_outlined;
    } else if (name.contains('ara') || name.contains('snack')) {
      return Icons.cookie_outlined;
    }
    return Icons.restaurant_outlined;
  }
}
