import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/repositories/focus_session_repository.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';

/// Canonical per-day execution totals used across Today, Daily Brief, and Review.
class DayExecutionSummary {
  const DayExecutionSummary({
    required this.tasksCompleted,
    required this.focusSeconds,
    required this.sessionCount,
  });

  final int tasksCompleted;
  final int focusSeconds;
  final int sessionCount;

  double get focusHours => focusSeconds / 3600;
}

DateTime normalizeCalendarDay(DateTime day) {
  return DateTime(day.year, day.month, day.day);
}

int countTasksCompletedOnDay(List<Task> allTasks, DateTime day) {
  return allTasks
      .where((task) => taskCompletedToday(task, now: normalizeCalendarDay(day)))
      .length;
}

List<FocusSessionRecord> sessionsOnDay(
  List<FocusSessionRecord> sessions,
  DateTime day,
) {
  final dayStart = normalizeCalendarDay(day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  return sessions.where((session) {
    final ended = session.endedAt;
    if (ended == null) {
      return false;
    }
    return !ended.isBefore(dayStart) && ended.isBefore(dayEnd);
  }).toList();
}

/// Uses the higher of persisted daily stats and completed session totals.
int resolveFocusSecondsForDay({
  required List<FocusSessionRecord> sessions,
  required int persistedFocusSeconds,
}) {
  final sessionSeconds = sessions.fold<int>(
    0,
    (sum, session) => sum + session.durationSeconds,
  );
  return sessionSeconds > persistedFocusSeconds
      ? sessionSeconds
      : persistedFocusSeconds;
}

Future<DayExecutionSummary> loadDayExecutionSummary({
  required DateTime day,
  required List<Task> allTasks,
  required FocusSessionRepository focusRepo,
  int additionalFocusSeconds = 0,
}) async {
  final normalized = normalizeCalendarDay(day);
  final persisted = await DailyActivityStats.focusSecondsFor(normalized);
  final sessions = await focusRepo.getCompletedSessionsForDay(normalized);
  final focusSeconds = resolveFocusSecondsForDay(
    sessions: sessions,
    persistedFocusSeconds: persisted,
  );

  return DayExecutionSummary(
    tasksCompleted: countTasksCompletedOnDay(allTasks, normalized),
    focusSeconds: focusSeconds + additionalFocusSeconds,
    sessionCount: sessions.length,
  );
}

Future<List<int>> loadMergedFocusSecondsForWeek({
  required DateTime weekMonday,
  required FocusSessionRepository focusRepo,
}) async {
  final monday = normalizeCalendarDay(weekMonday);
  final persisted = await DailyActivityStats.focusSecondsForWeek(monday);
  final sessions = await focusRepo.getCompletedSessionsForWeek(monday);

  return List.generate(7, (index) {
    final day = monday.add(Duration(days: index));
    return resolveFocusSecondsForDay(
      sessions: sessionsOnDay(sessions, day),
      persistedFocusSeconds: persisted[index],
    );
  });
}
