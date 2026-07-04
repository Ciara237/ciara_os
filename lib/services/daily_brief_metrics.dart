import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/services/day_execution_stats.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';

class YesterdaySummary {
  const YesterdaySummary({
    required this.tasksCompleted,
    required this.focusHours,
    required this.sessionCount,
  });

  final int tasksCompleted;
  final double focusHours;
  final int sessionCount;
}

class AbsenceStatus {
  const AbsenceStatus({
    required this.overdueTaskCount,
    required this.activeProjectCount,
    required this.weeklyReviewPending,
    this.mostOverdueTask,
    this.topActiveProject,
  });

  final int overdueTaskCount;
  final int activeProjectCount;
  final bool weeklyReviewPending;
  final Task? mostOverdueTask;
  final Project? topActiveProject;
}

YesterdaySummary computeYesterdaySummary({
  required List<Task> allTasks,
  required List<FocusSessionRecord> sessions,
  required int persistedFocusSeconds,
  DateTime? day,
}) {
  final targetDay = normalizeCalendarDay(
    day ?? DateTime.now().subtract(const Duration(days: 1)),
  );
  final focusSeconds = resolveFocusSecondsForDay(
    sessions: sessions,
    persistedFocusSeconds: persistedFocusSeconds,
  );

  return YesterdaySummary(
    tasksCompleted: countTasksCompletedOnDay(allTasks, targetDay),
    focusHours: focusSeconds / 3600,
    sessionCount: sessions.length,
  );
}

int countOverdueTasks(List<Task> allTasks) {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  return allTasks.where((task) {
    if (task.status == TaskStatus.done || task.deadline == null) {
      return false;
    }
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );
    return deadline.isBefore(todayStart);
  }).length;
}

Task? mostOverdueTask(List<Task> allTasks) {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final overdue = allTasks.where((task) {
    if (task.status == TaskStatus.done || task.deadline == null) {
      return false;
    }
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );
    return deadline.isBefore(todayStart);
  }).toList();

  if (overdue.isEmpty) {
    return null;
  }

  overdue.sort((a, b) => a.deadline!.compareTo(b.deadline!));
  return overdue.first;
}

Project? topActiveProject(List<Project> projects) {
  for (final project in projects) {
    if (project.status == ProjectStatus.active) {
      return project;
    }
  }
  return null;
}

bool isWeeklyReviewPending(WeeklyReview? review) {
  if (review == null) {
    return true;
  }
  return !review.locked;
}

AbsenceStatus computeAbsenceStatus({
  required List<Task> allTasks,
  required List<Project> projects,
  required WeeklyReview? weekReview,
}) {
  return AbsenceStatus(
    overdueTaskCount: countOverdueTasks(allTasks),
    activeProjectCount: projects
        .where((project) => project.status == ProjectStatus.active)
        .length,
    weeklyReviewPending: isWeeklyReviewPending(weekReview),
    mostOverdueTask: mostOverdueTask(allTasks),
    topActiveProject: topActiveProject(projects),
  );
}

Task? topPriorityTask(List<Task> tasks) {
  if (tasks.isEmpty) {
    return null;
  }

  const order = {
    Priority.critical: 0,
    Priority.high: 1,
    Priority.medium: 2,
    Priority.low: 3,
  };

  final sorted = [...tasks]
    ..sort(
      (a, b) => order[a.priority]!.compareTo(order[b.priority]!),
    );
  return sorted.first;
}

enum BufferTaskBadge { overdue, critical, deepWork }

class BufferTaskEntry {
  const BufferTaskEntry({
    required this.task,
    required this.badge,
    required this.accentColor,
  });

  final Task task;
  final BufferTaskBadge badge;
  final Color accentColor;
}

bool isTaskOverdue(Task task) {
  if (task.status == TaskStatus.done || task.deadline == null) {
    return false;
  }
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final deadline = DateTime(
    task.deadline!.year,
    task.deadline!.month,
    task.deadline!.day,
  );
  return deadline.isBefore(todayStart);
}

BufferTaskBadge badgeForTask(Task task) {
  if (isTaskOverdue(task)) {
    return BufferTaskBadge.overdue;
  }
  if (task.priority == Priority.critical) {
    return BufferTaskBadge.critical;
  }
  return BufferTaskBadge.deepWork;
}

Color accentForBadge(BufferTaskBadge badge) {
  return switch (badge) {
    BufferTaskBadge.overdue => AppColors.darkError,
    BufferTaskBadge.critical => AppColors.darkTertiary,
    BufferTaskBadge.deepWork => AppColors.darkPrimary,
  };
}

String labelForBadge(BufferTaskBadge badge) {
  return switch (badge) {
    BufferTaskBadge.overdue => 'OVERDUE',
    BufferTaskBadge.critical => 'CRITICAL',
    BufferTaskBadge.deepWork => 'DEEP WORK',
  };
}

String domainPriorityLabel(Domain domain) {
  final label = domainLabel(domain);
  if (label.isEmpty) {
    return 'Priority';
  }
  return '${label[0]}${label.substring(1).toLowerCase()} Priority';
}

List<BufferTaskEntry> highPriorityBufferTasks(
  List<Task> allTasks, {
  int limit = 3,
}) {
  int rank(Task task) {
    if (isTaskOverdue(task)) {
      return 0;
    }
    return switch (task.priority) {
      Priority.critical => 1,
      Priority.high => 2,
      Priority.medium => 3,
      Priority.low => 4,
    };
  }

  final candidates = allTasks
      .where((task) => task.status != TaskStatus.done)
      .where((task) {
        if (isTaskOverdue(task)) {
          return true;
        }
        return task.priority == Priority.critical ||
            task.priority == Priority.high ||
            task.today;
      })
      .toList()
    ..sort((a, b) {
      final rankCompare = rank(a).compareTo(rank(b));
      if (rankCompare != 0) {
        return rankCompare;
      }
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      return a.deadline != null ? -1 : 1;
    });

  return candidates.take(limit).map((task) {
    final badge = badgeForTask(task);
    return BufferTaskEntry(
      task: task,
      badge: badge,
      accentColor: accentForBadge(badge),
    );
  }).toList();
}

int countIncompleteHighPriority(List<Task> allTasks) {
  return allTasks
      .where((task) => task.status != TaskStatus.done)
      .where(
        (task) =>
            isTaskOverdue(task) ||
            task.priority == Priority.critical ||
            task.priority == Priority.high,
      )
      .length;
}

/// Target route for welcome-back RE-ENGAGE (priority recovery path).
String reEngageDestination(AbsenceStatus status) {
  if (status.overdueTaskCount > 0 && status.mostOverdueTask != null) {
    return '/tasks/${status.mostOverdueTask!.id}';
  }
  if (status.weeklyReviewPending) {
    return '/review';
  }
  if (status.topActiveProject != null) {
    return '/projects/${status.topActiveProject!.id}';
  }
  return '/';
}
