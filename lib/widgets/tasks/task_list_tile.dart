import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Task row for Today / Backlog lists. Extended from onboarding demo.
class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
    this.onTap,
    this.onStartedToggle,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStartedToggle;

  /// Demo task shown on onboarding step 3.
  static Task demoTask() {
    final now = DateTime.now();
    return Task(
      id: 0,
      title: 'System Architecture',
      domain: Domain.engineering,
      status: TaskStatus.inProgress,
      priority: Priority.medium,
      started: true,
      today: false,
      notes: 'Design token integration',
      postponeCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  String? get _subtitle {
    final notes = task.notes?.trim();
    if (notes == null || notes.isEmpty) {
      return null;
    }
    return notes.split('\n').first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: AppSpacing.taskBorderWidth,
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (_subtitle != null) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StartedToggleButton(
                          started: task.started,
                          domainColor: domainColor,
                          onPressed: onStartedToggle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartedToggleButton extends StatelessWidget {
  const StartedToggleButton({
    super.key,
    required this.started,
    required this.domainColor,
    this.onPressed,
  });

  final bool started;
  final Color domainColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (started) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.play_arrow,
          size: AppSpacing.md,
          color: colorScheme.onPrimary,
        ),
        label: Text(
          '▶ STARTED',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: domainColor,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.play_arrow,
        size: AppSpacing.md,
        color: colorScheme.onSurfaceVariant,
      ),
      label: Text(
        '▶ STARTED',
        style: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}
