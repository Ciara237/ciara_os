import 'package:ciaraos/models/project.dart';

/// Whole days elapsed since the project was created (local calendar days).
int projectElapsedDays(Project project) {
  final created = DateTime(
    project.createdAt.year,
    project.createdAt.month,
    project.createdAt.day,
  );
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(created).inDays;
}

/// Days left in the project's time allocation window.
int projectRemainingDays(Project project) {
  final remaining = project.timeAllocationDays - projectElapsedDays(project);
  if (remaining <= 0) {
    return 0;
  }
  if (remaining > project.timeAllocationDays) {
    return project.timeAllocationDays;
  }
  return remaining;
}
