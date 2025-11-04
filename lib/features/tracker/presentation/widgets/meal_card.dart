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
    final totalCalories = meal.totalCalories; // Getter'ımızı kullanıyoruz.

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.name, style: Theme.of(context).textTheme.titleLarge),
            Text(
              '$totalCalories kcal',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),

            const Divider(height: 16),
            Column(
              children: meal.loggedFoods.map((food) {
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text(
                    '${food.quantity.toString()} ${food.unit.label}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${food.calories.toInt()} kcal'),
                      if (isToday)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(context, ref, food),
                        ),
                    ],
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
