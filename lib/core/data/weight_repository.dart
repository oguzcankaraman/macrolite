import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrolite/core/domain/weight_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_repository.g.dart';

class WeightRepository {
  WeightRepository(this.weightBox);

  final Box<WeightEntry> weightBox;

  /// Get all weight entries sorted by date (newest first)
  List<WeightEntry> getAllWeightEntries() {
    try {
      final entries = weightBox.values.toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      return [];
    }
  }

  /// Get weight entries within a date range
  List<WeightEntry> getWeightEntriesInRange({
    required DateTime start,
    required DateTime end,
  }) {
    try {
      final allEntries = weightBox.values.toList();
      final filtered = allEntries.where((entry) {
        return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
            entry.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
      filtered.sort((a, b) => a.date.compareTo(b.date));
      return filtered;
    } catch (e) {
      return [];
    }
  }

  /// Get the most recent weight entry
  WeightEntry? getLatestWeightEntry() {
    try {
      final entries = getAllWeightEntries();
      return entries.isNotEmpty ? entries.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Add a new weight entry
  Future<void> addWeightEntry(WeightEntry entry) async {
    // Use date as key to ensure uniqueness per day
    final key = entry.date.millisecondsSinceEpoch;
    await weightBox.put(key, entry);
  }

  /// Update an existing weight entry
  Future<void> updateWeightEntry(DateTime date, double weight) async {
    final key = date.millisecondsSinceEpoch;
    final entry = WeightEntry(date: date, weight: weight);
    await weightBox.put(key, entry);
  }

  /// Delete a weight entry
  Future<void> deleteWeightEntry(DateTime date) async {
    final key = date.millisecondsSinceEpoch;
    await weightBox.delete(key);
  }

  /// Clear all weight entries
  Future<void> clearAllEntries() async {
    await weightBox.clear();
  }
}

@riverpod
Future<WeightRepository> weightRepository(WeightRepositoryRef ref) async {
  final weightBox = await ref.watch(weightBoxProvider.future);
  return WeightRepository(weightBox);
}

@riverpod
Future<Box<WeightEntry>> weightBox(WeightBoxRef ref) async {
  ref.keepAlive();
  return await Hive.openBox<WeightEntry>('weight_entries');
}
