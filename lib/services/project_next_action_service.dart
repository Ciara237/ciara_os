import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/repositories/project_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _priorityOrder = {
  Priority.critical: 0,
  Priority.high: 1,
  Priority.medium: 2,
  Priority.low: 3,
};

/// Incomplete tasks linked to [projectId], highest priority first, then oldest.
List<Task> projectBacklogTasks(List<Task> allTasks, int projectId) {
  final backlog = allTasks
      .where(
        (task) =>
            task.projectId == projectId && task.status != TaskStatus.done,
      )
      .toList()
    ..sort((a, b) {
      final priorityCompare = _priorityOrder[a.priority]!
          .compareTo(_priorityOrder[b.priority]!);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  return backlog;
}

/// Title of the next backlog task, or null when the backlog is empty.
String? resolveNextActionFromBacklog(List<Task> allTasks, int projectId) {
  final backlog = projectBacklogTasks(allTasks, projectId);
  if (backlog.isEmpty) {
    return null;
  }
  return backlog.first.title;
}

/// What to show on project surfaces — backlog task title wins over stored text.
String? displayNextAction(Project project, List<Task> allTasks) {
  return resolveNextActionFromBacklog(allTasks, project.id) ??
      project.nextAction;
}

Future<void> persistProjectNextAction(
  ProjectRepository projectRepo,
  Project project,
  String? nextAction,
) async {
  await projectRepo.update(
    project
        .copyWith(
          nextAction: nextAction,
          clearNextAction: nextAction == null,
          updatedAt: DateTime.now(),
        )
        .toCompanion(),
  );
}

/// After a linked task is completed, point the project at the next backlog task.
Future<void> syncProjectNextActionAfterTaskComplete(
  WidgetRef ref,
  Task completedTask,
) async {
  final projectId = completedTask.projectId;
  if (projectId == null) {
    return;
  }

  final projectRepo = ref.read(projectRepositoryProvider);
  final project = await projectRepo.getById(projectId);
  if (project == null) {
    return;
  }

  final allTasks = await ref.read(allTasksProvider.future);
  final nextTitle = resolveNextActionFromBacklog(allTasks, projectId);
  await persistProjectNextAction(projectRepo, project, nextTitle);
  ref.invalidate(projectByIdProvider(projectId));
}

/// Save a manually entered next action and create a backlog task when needed.
Future<void> saveProjectNextActionWithTask(
  WidgetRef ref,
  Project project,
  String rawText,
) async {
  final trimmed = rawText.trim();
  final projectRepo = ref.read(projectRepositoryProvider);
  final taskRepo = ref.read(taskRepositoryProvider);
  final now = DateTime.now();

  await persistProjectNextAction(
    projectRepo,
    project,
    trimmed.isEmpty ? null : trimmed,
  );

  if (trimmed.isNotEmpty) {
    final allTasks = await ref.read(allTasksProvider.future);
    final backlog = projectBacklogTasks(allTasks, project.id);
    final alreadyInBacklog = backlog.any(
      (task) => task.title.toLowerCase() == trimmed.toLowerCase(),
    );

    if (!alreadyInBacklog) {
      await taskRepo.insert(
        Task(
          id: 0,
          title: trimmed,
          domain: project.domain,
          status: TaskStatus.notStarted,
          priority: Priority.medium,
          started: false,
          today: false,
          projectId: project.id,
          postponeCount: 0,
          totalFocusedSeconds: 0,
          focusSessionCount: 0,
          createdAt: now,
          updatedAt: now,
        ).toCompanion(forInsert: true),
      );
    }
  }

  ref.invalidate(projectByIdProvider(project.id));
}
