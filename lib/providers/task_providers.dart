import 'package:ciaraos/models/domain_analytics.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/planning_accuracy_data.dart';
import 'package:ciaraos/models/productivity_trends_data.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/services/domain_analytics_service.dart';
import 'package:ciaraos/services/planning_accuracy_service.dart';
import 'package:ciaraos/services/productivity_trends_service.dart';
import 'package:ciaraos/services/task_completion_service.dart';
import 'package:ciaraos/services/day_execution_stats.dart';
import 'package:ciaraos/utils/planning_accuracy_utils.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});

final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchToday();
});

final taskByIdProvider = FutureProvider.family<Task?, int>((ref, id) {
  return ref.read(taskRepositoryProvider).getById(id);
});

final weekTasksProvider = FutureProvider.family<List<Task>, DateTime>(
  (ref, weekStart) async {
    final normalizedStart = mondayOfWeek(weekStart);
    return ref.read(taskRepositoryProvider).getTasksForWeek(normalizedStart);
  },
);

final weekCompletedTasksProvider = FutureProvider.family<List<Task>, DateTime>(
  (ref, weekStart) async {
    final normalizedStart = mondayOfWeek(weekStart);
    return ref
        .read(taskRepositoryProvider)
        .getTasksCompletedInWeek(normalizedStart);
  },
);

final domainFilterProvider = StateProvider<Domain?>((ref) => null);

final deadlineFilterProvider = StateProvider<String?>((ref) => null);

final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final domain = ref.watch(domainFilterProvider);
  final deadline = ref.watch(deadlineFilterProvider);
  final status = ref.watch(statusFilterProvider);

  return tasksAsync.whenData(
    (tasks) => applyTaskFilters(
      tasks: tasks,
      domain: domain,
      deadline: deadline,
      status: status,
      excludeDone: true,
    ),
  );
});

final domainBreakdownPeriodProvider = StateProvider<String>((ref) => 'week');

final domainBreakdownProvider =
    FutureProvider.family<DomainBreakdownData, String>((ref, period) async {
  ref.watch(allTasksProvider);
  final tasks = await ref.watch(allTasksProvider.future);
  final focusRepo = ref.read(focusSessionRepositoryProvider);

  List<FocusSessionRecord> sessions = const [];
  if (period == 'week') {
    final weekMonday = mondayOfWeek(DateTime.now());
    sessions = await focusRepo.getCompletedSessionsForWeek(weekMonday);
  } else if (period == 'month') {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final weeksInMonth = <DateTime>{};
    for (var day = 0; day < 31; day++) {
      final date = monthStart.add(Duration(days: day));
      if (date.month != monthStart.month) {
        break;
      }
      weeksInMonth.add(mondayOfWeek(date));
    }
    final sessionLists = await Future.wait(
      weeksInMonth.map(focusRepo.getCompletedSessionsForWeek),
    );
    sessions = sessionLists.expand((list) => list).toList();
  }

  return DomainAnalyticsService().compute(
    tasks: tasks,
    sessions: sessions,
    period: period,
  );
});

final planningAccuracyProvider = FutureProvider<PlanningAccuracyData>((ref) async {
  ref.watch(allTasksProvider);
  final repository = ref.read(taskRepositoryProvider);
  final tasks = await ref.watch(allTasksProvider.future);

  for (final task in tasks) {
    if (taskHasPlanningAccuracyInputs(task) && task.planningAccuracy == null) {
      await persistPlanningAccuracyForTask(repository, task.id);
    }
  }

  final refreshedTasks = await Future.wait(
    tasks.map((task) async {
      if (taskHasPlanningAccuracyInputs(task) && task.planningAccuracy == null) {
        return await repository.getById(task.id) ?? task;
      }
      return task;
    }),
  );

  return PlanningAccuracyService().compute(refreshedTasks);
});

final productivityTrendsProvider =
    FutureProvider<ProductivityTrendsData>((ref) async {
  ref.watch(allWeeklyReviewsProvider);
  final reviews = await ref.watch(allWeeklyReviewsProvider.future);
  final focusRepo = ref.read(focusSessionRepositoryProvider);
  final now = DateTime.now();
  final currentWeekStart = mondayOfWeek(now);

  final focusHoursByWeek = <DateTime, double>{};
  for (var index = 0; index < 8; index++) {
    final weeksAgo = 7 - index;
    final weekStart = currentWeekStart.subtract(Duration(days: weeksAgo * 7));
    final dailySeconds = await loadMergedFocusSecondsForWeek(
      weekMonday: weekStart,
      focusRepo: focusRepo,
    );
    focusHoursByWeek[weekStart] =
        dailySeconds.fold<int>(0, (sum, seconds) => sum + seconds) / 3600.0;
  }

  return ProductivityTrendsService().compute(
    reviews: reviews,
    focusHoursByWeek: focusHoursByWeek,
  );
});
