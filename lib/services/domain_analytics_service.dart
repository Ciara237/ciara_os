import 'package:ciaraos/models/domain_analytics.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/utils/domain_icons.dart';

class DomainAnalyticsService {
  DomainBreakdownData compute({
    required List<Task> tasks,
    required List<FocusSessionRecord> sessions,
    required String period,
  }) {
    final filtered = filterTasksByPeriod(tasks, period);
    final focusByDomain = _focusedSecondsByDomain(filtered, sessions);
    final stats = <DomainStats>[];

    for (final domain in Domain.values) {
      final domainTasks =
          filtered.where((task) => task.domain == domain).toList();
      final total = domainTasks.length;
      final completed =
          domainTasks.where((t) => t.status == TaskStatus.done).length;
      final inProgress =
          domainTasks.where((t) => t.status == TaskStatus.inProgress).length;
      final stuck =
          domainTasks.where((t) => t.status == TaskStatus.stuck).length;
      final started =
          domainTasks.where((task) => task.started).length;

      String? mostPostponedTitle;
      var mostPostponedCount = 0;
      for (final task in domainTasks) {
        if (task.postponeCount > mostPostponedCount) {
          mostPostponedCount = task.postponeCount;
          mostPostponedTitle = task.title;
        }
      }

      stats.add(
        DomainStats(
          domain: domain,
          totalTasks: total,
          completedTasks: completed,
          inProgressTasks: inProgress,
          stuckTasks: stuck,
          totalFocusedSeconds: focusByDomain[domain] ?? 0,
          startedRate: total == 0 ? 0 : started / total,
          mostPostponedTaskTitle: mostPostponedCount > 0
              ? mostPostponedTitle
              : null,
          mostPostponedCount: mostPostponedCount,
          sharePercent: 0,
        ),
      );
    }

    final totalTasks = filtered.length;
    final distribution = <Domain, double>{};
    for (final stat in stats) {
      distribution[stat.domain] =
          totalTasks == 0 ? 0 : (stat.totalTasks / totalTasks) * 100;
    }

    final domainStats = stats
        .map(
          (stat) => DomainStats(
            domain: stat.domain,
            totalTasks: stat.totalTasks,
            completedTasks: stat.completedTasks,
            inProgressTasks: stat.inProgressTasks,
            stuckTasks: stat.stuckTasks,
            totalFocusedSeconds: stat.totalFocusedSeconds,
            startedRate: stat.startedRate,
            mostPostponedTaskTitle: stat.mostPostponedTaskTitle,
            mostPostponedCount: stat.mostPostponedCount,
            sharePercent: distribution[stat.domain] ?? 0,
          ),
        )
        .where((stat) => stat.totalTasks > 0)
        .toList()
      ..sort((a, b) => b.totalTasks.compareTo(a.totalTasks));

    final imbalanceAlerts = stats
        .where((stat) => stat.totalTasks == 0)
        .map(
          (stat) => DomainImbalanceAlert(
            domain: stat.domain,
            message:
                'Domain "${domainLabel(stat.domain)}" has 0 tasks for this period. Consider re-evaluating focus priorities.',
          ),
        )
        .toList();

    return DomainBreakdownData(
      period: period,
      totalTasks: totalTasks,
      distribution: distribution,
      domainStats: domainStats,
      imbalanceAlerts: imbalanceAlerts,
    );
  }

  static List<Task> filterTasksByPeriod(List<Task> tasks, String period) {
    if (period == 'all') {
      return List<Task>.from(tasks);
    }

    final now = DateTime.now();
    final start = switch (period) {
      'week' => _startOfWeek(now),
      'month' => DateTime(now.year, now.month),
      _ => null,
    };

    if (start == null) {
      return List<Task>.from(tasks);
    }

    return tasks
        .where(
          (task) =>
              !task.updatedAt.isBefore(start) || !task.createdAt.isBefore(start),
        )
        .toList();
  }

  static DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static Map<Domain, int> _focusedSecondsByDomain(
    List<Task> tasks,
    List<FocusSessionRecord> sessions,
  ) {
    final taskDomain = {for (final task in tasks) task.id: task.domain};
    final totals = {
      for (final domain in Domain.values) domain: 0,
    };

    if (sessions.isNotEmpty) {
      for (final session in sessions) {
        final domain = taskDomain[session.taskId];
        if (domain == null) {
          continue;
        }
        totals[domain] = totals[domain]! + session.durationSeconds;
      }
      return totals;
    }

    for (final task in tasks) {
      totals[task.domain] = totals[task.domain]! + task.totalFocusedSeconds;
    }
    return totals;
  }
}
