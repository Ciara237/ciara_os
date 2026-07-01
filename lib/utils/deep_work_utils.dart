import 'package:ciaraos/models/task.dart';

/// Standard deep work block length (seconds).
const deepWorkGoalSeconds = 45 * 60;

/// Default estimate when none is set (minutes).
const defaultEstimatedMinutes = 45;

int plannedSessionCount(Task task) {
  final minutes = task.estimatedDurationMinutes ?? defaultEstimatedMinutes;
  return (minutes / 45).ceil().clamp(1, 99);
}

int currentSessionNumber(Task task, {required bool isActiveForTask}) {
  final base = task.focusSessionCount;
  return isActiveForTask ? base + 1 : base.clamp(1, 99);
}

/// Planning accuracy 0–100: 100 = perfect estimate.
double? computePlanningAccuracy({
  required int? estimatedMinutes,
  required int totalFocusedSeconds,
}) {
  if (estimatedMinutes == null || estimatedMinutes <= 0) {
    return null;
  }
  final estimatedSeconds = estimatedMinutes * 60;
  if (totalFocusedSeconds <= 0) {
    return 0;
  }
  final ratio = estimatedSeconds / totalFocusedSeconds;
  final symmetry = ratio < 1 ? ratio : 1 / ratio;
  return (symmetry * 100).clamp(0, 100);
}

String formatDurationMinutes(int totalSeconds) {
  if (totalSeconds <= 0) {
    return '0m';
  }
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}

String formatEstimatedMinutes(int? minutes) {
  if (minutes == null || minutes <= 0) {
    return '—';
  }
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
  return '${minutes}m';
}

String formatPlanningAccuracy(double? accuracy) {
  if (accuracy == null) {
    return '—';
  }
  return '${accuracy.round()}%';
}

double? averageQualityScore(List<double> scores) {
  if (scores.isEmpty) {
    return null;
  }
  return scores.reduce((a, b) => a + b) / scores.length;
}

String formatAverageQuality(double? avgScore) {
  if (avgScore == null) {
    return '—';
  }
  if (avgScore >= 3.5) {
    return 'Deep';
  }
  if (avgScore >= 2.5) {
    return 'Good';
  }
  if (avgScore >= 1.5) {
    return 'Okay';
  }
  return 'Mixed';
}
