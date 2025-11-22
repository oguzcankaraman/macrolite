import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:macrolite/core/domain/daily_macro_summary.dart';
import 'package:macrolite/features/tracker/data/tracker_repository.dart';

part 'daily_summaries_provider.g.dart';

@riverpod
Future<List<DailyMacroSummary>> dailySummaries(
  DailySummariesRef ref, {
  required DateTime start,
  required DateTime end,
}) {
  return ref
      .watch(trackerRepositoryProvider)
      .getDailySummaries(start: start, end: end);
}
