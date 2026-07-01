import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final todayDomainFilterProvider = StateProvider<Domain?>((ref) => null);
final todayDeadlineFilterProvider = StateProvider<String?>((ref) => null);
final todayStatusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final filteredTodayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(todayTasksProvider);
  final domain = ref.watch(todayDomainFilterProvider);
  final deadline = ref.watch(todayDeadlineFilterProvider);
  final status = ref.watch(todayStatusFilterProvider);

  return tasksAsync.whenData(
    (tasks) => applyTaskFilters(
      tasks: tasks,
      domain: domain,
      deadline: deadline,
      status: status,
    ),
  );
});

class TodayPerformanceSnapshot {
  const TodayPerformanceSnapshot({
    required this.completedToday,
    required this.totalToday,
    required this.focusSeconds,
    required this.dailyStreak,
    required this.sessionCountToday,
    required this.averageQualityScore,
    required this.planningAccuracy,
  });

  final int completedToday;
  final int totalToday;
  final int focusSeconds;
  final int dailyStreak;
  final int sessionCountToday;
  final double? averageQualityScore;
  final double? planningAccuracy;
}

final todayPerformanceProvider =
    FutureProvider<TodayPerformanceSnapshot>((ref) async {
  ref.watch(focusSessionProvider);
  ref.watch(dailyStatsRevisionProvider);
  final tasksAsync = ref.watch(todayTasksProvider);
  final tasks = tasksAsync.value ?? const <Task>[];

  final completed =
      tasks.where((task) => task.status == TaskStatus.done).length;
  final persistedFocus = await DailyActivityStats.todayFocusSeconds();
  final session = ref.read(focusSessionProvider);
  final sessionFocus = session.isActive
      ? ref.read(focusSessionProvider.notifier).unflushedFocusSeconds
      : 0;

  final focusRepo = ref.read(focusSessionRepositoryProvider);
  final todaySessions =
      await focusRepo.getCompletedSessionsForDay(DateTime.now());
  final qualityScores = todaySessions
      .where((s) => s.focusQuality != null)
      .map((s) => focusQualityScore(s.focusQuality!).toDouble())
      .toList();

  final accuracyValues = tasks
      .where((t) => t.planningAccuracy != null)
      .map((t) => t.planningAccuracy!)
      .toList();
  double? avgAccuracy;
  if (accuracyValues.isNotEmpty) {
    avgAccuracy =
        accuracyValues.reduce((a, b) => a + b) / accuracyValues.length;
  }

  return TodayPerformanceSnapshot(
    completedToday: completed,
    totalToday: tasks.length,
    focusSeconds: persistedFocus + sessionFocus,
    dailyStreak: await DailyActivityStats.dailyStreak(),
    sessionCountToday: todaySessions.length +
        (session.isActive ? 1 : 0),
    averageQualityScore: qualityScores.isEmpty
        ? null
        : qualityScores.reduce((a, b) => a + b) / qualityScores.length,
    planningAccuracy: avgAccuracy,
  );
});

void clearTodayFilters(WidgetRef ref) {
  ref.read(todayDomainFilterProvider.notifier).state = null;
  ref.read(todayDeadlineFilterProvider.notifier).state = null;
  ref.read(todayStatusFilterProvider.notifier).state = null;
}

bool hasActiveTodayFilters({
  Domain? domain,
  String? deadline,
  TaskStatus? status,
}) {
  return domain != null || deadline != null || status != null;
}
