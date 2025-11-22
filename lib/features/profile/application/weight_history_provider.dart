import 'package:macrolite/core/data/weight_repository.dart';
import 'package:macrolite/core/domain/weight_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_history_provider.g.dart';

@riverpod
Future<List<WeightEntry>> weightHistory(
  WeightHistoryRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return repository.getWeightEntriesInRange(start: start, end: end);
}

@riverpod
Future<WeightEntry?> latestWeight(LatestWeightRef ref) async {
  final repository = await ref.watch(weightRepositoryProvider.future);
  return repository.getLatestWeightEntry();
}
