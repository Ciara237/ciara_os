import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isEditingNotes = false;
  bool _isUpdating = false;
  bool? _optimisticStarted;
  late final TextEditingController _notesController;

  int get _id => int.parse(widget.taskId);

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _persistTask(Task task) async {
    await ref.read(taskRepositoryProvider).update(
          task.copyWith(updatedAt: DateTime.now()).toCompanion(),
        );
    ref.invalidate(taskByIdProvider(_id));
  }

  bool _displayStarted(Task task) => _optimisticStarted ?? task.started;

  Future<void> _toggleStarted(Task task) async {
    if (_isUpdating) {
      return;
    }

    final next = !_displayStarted(task);
    setState(() {
      _optimisticStarted = next;
      _isUpdating = true;
    });

    try {
      await _persistTask(task.copyWith(started: next));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _optimisticStarted = null;
        });
      }
    }
  }

  Future<void> _toggleToday(Task task) async {
    await _persistTask(task.copyWith(today: !task.today));
  }

  Future<void> _pickDeadline(Task task) async {
    final now = DateTime.now();
    final initial = task.deadline ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) {
      return;
    }
    await _persistTask(task.copyWith(deadline: picked));
  }

  Future<void> _saveNotes(Task task) async {
    final text = _notesController.text.trim();
    await _persistTask(
      task.copyWith(
        notes: text.isEmpty ? null : text,
        clearNotes: text.isEmpty,
      ),
    );
    if (mounted) {
      setState(() => _isEditingNotes = false);
    }
  }

  Future<void> _deleteTask(Task task) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete task?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will permanently remove "${task.title}".',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(taskRepositoryProvider).delete(task.id);
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskAsync = ref.watch(taskByIdProvider(_id));

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          TaskDetailHeader(taskId: widget.taskId),
          Expanded(
            child: taskAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load task.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (task) {
                if (task == null) {
                  return Center(
                    child: Text(
                      'Task not found.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                if (!_isEditingNotes &&
                    _notesController.text.isEmpty &&
                    task.notes != null) {
                  _notesController.text = task.notes!;
                }

                final hasNotes =
                    task.notes != null && task.notes!.trim().isNotEmpty;
                final showNotesCard = hasNotes || _isEditingNotes;
                final started = _displayStarted(task);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    TaskIdentitySection(task: task),
                    const SizedBox(height: AppSpacing.lg),
                    TaskDetailStartedToggle(
                      started: started,
                      domainColor: context.domainColor(task.domain),
                      isUpdating: _isUpdating,
                      onPressed: () => _toggleStarted(task),
                    ),
                    if (task.deadline != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      TaskDeadlineCard(
                        deadline: task.deadline!,
                        onEditDeadline: () => _pickDeadline(task),
                      ),
                    ],
                    if (task.projectId != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      TaskLinkedProjectCard(projectId: task.projectId!),
                    ],
                    if (showNotesCard) ...[
                      const SizedBox(height: AppSpacing.lg),
                      TaskNotesCard(
                        isEditing: _isEditingNotes,
                        notes: task.notes,
                        controller: _notesController,
                        onEdit: () => setState(() => _isEditingNotes = true),
                        onSave: () => _saveNotes(task),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    TaskMetadataSection(
                      createdAt: task.createdAt,
                      updatedAt: task.updatedAt,
                      postponeCount: task.postponeCount,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TaskDetailActionRow(
                      today: task.today,
                      onToggleToday: () => _toggleToday(task),
                      onDelete: () => _deleteTask(task),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailHeader extends StatelessWidget {
  const TaskDetailHeader({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Icon(Icons.terminal, color: colorScheme.primary, size: AppSpacing.lg),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Ciara OS',
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/tasks/$taskId/edit'),
            icon: Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class TaskIdentitySection extends StatelessWidget {
  const TaskIdentitySection({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);
    final priorityColor = priorityColorFor(task.priority);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DomainChip(
              label: domainShortLabel(task.domain),
              color: domainColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            _PriorityBadge(
              label: priorityLabelFor(task.priority),
              color: priorityColor,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          task.title,
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _StatusChip(label: taskStatusLabel(task.status)),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class TaskDetailStartedToggle extends StatelessWidget {
  const TaskDetailStartedToggle({
    super.key,
    required this.started,
    required this.domainColor,
    required this.isUpdating,
    required this.onPressed,
  });

  final bool started;
  final Color domainColor;
  final bool isUpdating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const minHeight = 56.0;

    if (started) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isUpdating ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(minHeight),
            backgroundColor: domainColor,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            '▶ TASK STARTED',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isUpdating ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(minHeight),
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.onSurfaceVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          '▶ START TASK',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class TaskDeadlineCard extends StatelessWidget {
  const TaskDeadlineCard({
    super.key,
    required this.deadline,
    required this.onEditDeadline,
  });

  final DateTime deadline;
  final VoidCallback onEditDeadline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEADLINE',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TaskDeadlineIndicator(deadline: deadline),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onEditDeadline,
            child: Text(
              'Edit deadline',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TaskDeadlineKind { future, dueSoon, dueToday, overdue }

class _TaskDeadlineIndicator extends StatelessWidget {
  const _TaskDeadlineIndicator({required this.deadline});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    final daysUntil = due.difference(today).inDays;

    final _TaskDeadlineKind kind;
    if (daysUntil < 0) {
      kind = _TaskDeadlineKind.overdue;
    } else if (daysUntil == 0) {
      kind = _TaskDeadlineKind.dueToday;
    } else if (daysUntil <= 3) {
      kind = _TaskDeadlineKind.dueSoon;
    } else {
      kind = _TaskDeadlineKind.future;
    }

    final Color color;
    final IconData icon;
    final String label;

    switch (kind) {
      case _TaskDeadlineKind.future:
        color = colorScheme.onSurfaceVariant;
        icon = Icons.calendar_today;
        label = DateFormat('MMM d, yyyy').format(deadline).toUpperCase();
      case _TaskDeadlineKind.dueSoon:
        color = AppColors.priorityHigh;
        icon = Icons.bolt;
        label = 'DUE IN $daysUntil ${daysUntil == 1 ? 'DAY' : 'DAYS'}';
      case _TaskDeadlineKind.dueToday:
        color = colorScheme.error;
        icon = Icons.bolt;
        label = 'DUE TODAY';
      case _TaskDeadlineKind.overdue:
        color = colorScheme.error;
        icon = Icons.schedule;
        label = 'OVERDUE';
    }

    return Row(
      children: [
        Icon(icon, size: AppSpacing.md, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodyLarge.copyWith(color: color),
        ),
      ],
    );
  }
}

class TaskLinkedProjectCard extends ConsumerWidget {
  const TaskLinkedProjectCard({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return projectAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (project) {
        if (project == null) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/projects/$projectId'),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LINKED PROJECT',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _LinkedProjectRow(project: project),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LinkedProjectRow extends StatelessWidget {
  const _LinkedProjectRow({required this.project});

  final Project project;

  static String _statusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => 'Active',
      ProjectStatus.paused => 'Paused',
      ProjectStatus.shipped => 'Shipped',
      ProjectStatus.archived => 'Archived',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(project.domain);

    return Row(
      children: [
        Expanded(
          child: Text(
            project.name,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          width: AppSpacing.sm,
          height: AppSpacing.sm,
          decoration: BoxDecoration(
            color: domainColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _statusLabel(project.status),
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
          size: AppSpacing.lg,
        ),
      ],
    );
  }
}

class TaskNotesCard extends StatelessWidget {
  const TaskNotesCard({
    super.key,
    required this.isEditing,
    required this.notes,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  final bool isEditing;
  final String? notes;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNotes = notes != null && notes!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'NOTES',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: isEditing ? onSave : onEdit,
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (isEditing)
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Add notes...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              hasNotes ? notes! : 'No notes added.',
              style: AppTypography.bodyMedium.copyWith(
                color: hasNotes
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class TaskMetadataSection extends StatelessWidget {
  const TaskMetadataSection({
    super.key,
    required this.createdAt,
    required this.updatedAt,
    required this.postponeCount,
  });

  final DateTime createdAt;
  final DateTime updatedAt;
  final int postponeCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final procrastinationSignal = postponeCount > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataRow(
          label: 'CREATED',
          value: DateFormat('MMM d, yyyy').format(createdAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'LAST MODIFIED',
          value: relativeTimeLabel(updatedAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'POSTPONED',
          value: '$postponeCount ${postponeCount == 1 ? 'time' : 'times'}',
          valueColor: procrastinationSignal
              ? AppColors.priorityHigh
              : colorScheme.onSurface,
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class TaskDetailActionRow extends StatelessWidget {
  const TaskDetailActionRow({
    super.key,
    required this.today,
    required this.onToggleToday,
    required this.onDelete,
  });

  final bool today;
  final VoidCallback onToggleToday;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: today
              ? FilledButton(
                  onPressed: onToggleToday,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: Text(
                    "In Today's Queue",
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                )
              : OutlinedButton(
                  onPressed: onToggleToday,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    'Add to Today',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: onDelete,
            child: Text(
              'DELETE',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color priorityColorFor(Priority priority) {
  return switch (priority) {
    Priority.low => AppColors.priorityLow,
    Priority.medium => AppColors.priorityMedium,
    Priority.high => AppColors.priorityHigh,
    Priority.critical => AppColors.priorityCritical,
  };
}

String priorityLabelFor(Priority priority) {
  return switch (priority) {
    Priority.low => 'LOW',
    Priority.medium => 'MEDIUM',
    Priority.high => 'HIGH',
    Priority.critical => 'CRITICAL',
  };
}

String taskStatusLabel(TaskStatus status) {
  return switch (status) {
    TaskStatus.notStarted => 'NOT STARTED',
    TaskStatus.inProgress => 'IN PROGRESS',
    TaskStatus.done => 'DONE',
    TaskStatus.stuck => 'STUCK',
  };
}
