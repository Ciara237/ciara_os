import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deadline filter keys stored in [deadlineFilterProvider].
abstract final class TaskDeadlineFilter {
  static const String today = 'today';
  static const String week = 'week';
  static const String month = 'month';
}

bool hasActiveTaskFilters({
  Domain? domain,
  String? deadline,
  TaskStatus? status,
}) {
  return domain != null || deadline != null || status != null;
}

List<Task> applyTaskFilters({
  required List<Task> tasks,
  Domain? domain,
  String? deadline,
  TaskStatus? status,
  bool excludeDone = false,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  var filtered = tasks;

  if (domain != null) {
    filtered = filtered.where((task) => task.domain == domain).toList();
  }

  if (status != null) {
    filtered = filtered.where((task) => task.status == status).toList();
  } else if (excludeDone) {
    filtered =
        filtered.where((task) => task.status != TaskStatus.done).toList();
  }

  if (deadline != null) {
    filtered = filtered.where((task) {
      final taskDeadline = task.deadline;
      if (taskDeadline == null) {
        return false;
      }
      return _matchesDeadlineFilter(taskDeadline, deadline, clock);
    }).toList();
  }

  filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return filtered;
}

bool _matchesDeadlineFilter(
  DateTime taskDeadline,
  String filter,
  DateTime now,
) {
  final deadline = DateTime(
    taskDeadline.year,
    taskDeadline.month,
    taskDeadline.day,
  );
  final today = DateTime(now.year, now.month, now.day);

  return switch (filter) {
    TaskDeadlineFilter.today => _isSameDay(deadline, today),
    TaskDeadlineFilter.week => _isInSameWeek(deadline, today),
    TaskDeadlineFilter.month =>
      deadline.year == today.year && deadline.month == today.month,
    _ => true,
  };
}

bool _isSameDay(DateTime a, DateTime b) => isSameCalendarDay(a, b);

bool isSameCalendarDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();
  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}

DateTime calendarDay(DateTime day) {
  final local = day.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Stable completion instant — [completedAt] when set, otherwise [updatedAt].
DateTime? taskCompletionInstant(Task task) {
  if (task.status != TaskStatus.done) {
    return null;
  }
  return task.completedAt ?? task.updatedAt;
}

bool taskCompletedOnDay(Task task, DateTime day) {
  final instant = taskCompletionInstant(task);
  if (instant == null) {
    return false;
  }
  return isSameCalendarDay(instant, day);
}

bool taskCompletedToday(Task task, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  return taskCompletedOnDay(task, clock);
}

/// Today's plan plus tasks completed today (even if removed from the today queue).
List<Task> tasksForPerformanceDay(List<Task> allTasks, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final seen = <int>{};

  return allTasks.where((task) {
    if (!task.today && !taskCompletedToday(task, now: clock)) {
      return false;
    }
    return seen.add(task.id);
  }).toList();
}

bool _isInSameWeek(DateTime date, DateTime anchor) {
  final weekStart = anchor.subtract(Duration(days: anchor.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  return !date.isBefore(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
      ) &&
      !date.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day));
}

enum TaskDeadlineDisplay { today, overdue, date, none }

TaskDeadlineDisplay deadlineDisplayFor(Task task, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);

  if (task.today) {
    return TaskDeadlineDisplay.today;
  }

  final deadline = task.deadline;
  if (deadline == null) {
    return TaskDeadlineDisplay.none;
  }

  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  if (deadlineDay.isBefore(today) && task.status != TaskStatus.done) {
    return TaskDeadlineDisplay.overdue;
  }

  if (_isSameDay(deadlineDay, today)) {
    return TaskDeadlineDisplay.today;
  }

  return TaskDeadlineDisplay.date;
}

void clearAllFilters(WidgetRef ref) {
  ref.read(domainFilterProvider.notifier).state = null;
  ref.read(deadlineFilterProvider.notifier).state = null;
  ref.read(statusFilterProvider.notifier).state = null;
}

/// Filter completed tasks by time period.
List<Task> filterCompletedByPeriod({
  required List<Task> tasks,
  required String period,
  DateTime? customStart,
  DateTime? customEnd,
}) {
  final completed = tasks.where((t) => t.status == TaskStatus.done).toList();

  final now = DateTime.now();

  switch (period) {
    case 'week':
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      return completed.where((t) {
        final date = t.completedAt ?? t.updatedAt;
        return date.isAfter(monday);
      }).toList();
    case 'month':
      final monthStart = DateTime(now.year, now.month, 1);
      return completed.where((t) {
        final date = t.completedAt ?? t.updatedAt;
        return date.isAfter(monthStart);
      }).toList();
    case 'custom':
      if (customStart == null) return completed;
      return completed.where((t) {
        final date = t.completedAt ?? t.updatedAt;
        return date.isAfter(customStart) &&
            (customEnd == null ||
                date.isBefore(customEnd.add(const Duration(days: 1))));
      }).toList();
    default: // 'all'
      return completed;
  }
}
