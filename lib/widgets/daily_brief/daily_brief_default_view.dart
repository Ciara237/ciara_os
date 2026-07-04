import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/services/project_next_action_service.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_shared.dart';
import 'package:flutter/material.dart';

class DailyBriefDefaultView extends StatelessWidget {
  const DailyBriefDefaultView({
    super.key,
    required this.greeting,
    required this.topTask,
    required this.todayCount,
    required this.activeProject,
    required this.allTasks,
    required this.yesterday,
    required this.onEnterToday,
  });

  final String greeting;
  final Task? topTask;
  final int todayCount;
  final Project? activeProject;
  final List<Task> allTasks;
  final YesterdaySummary yesterday;
  final VoidCallback? onEnterToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final task = topTask;
    final borderColor =
        task == null ? colorScheme.primary : context.domainColor(task.domain);
    final nextAction = activeProject == null
        ? null
        : displayNextAction(activeProject!, allTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          greeting,
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'System ready. Awaiting command.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DailyBriefCard(
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DailyBriefSectionLabel(
                label: "TODAY'S MISSION",
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (task != null) ...[
                Text(
                  task.title,
                  style: AppTypography.headingLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (task.estimatedDurationMinutes != null)
                      DailyBriefMetaChip(
                        icon: Icons.schedule_outlined,
                        label: '${task.estimatedDurationMinutes}m Estimated',
                      ),
                    DailyBriefMetaChip(
                      icon: Icons.priority_high,
                      iconColor: colorScheme.primary,
                      label: domainPriorityLabel(task.domain),
                    ),
                  ],
                ),
              ] else
                Text(
                  '$todayCount tasks queued for today',
                  style: AppTypography.headingLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DailyBriefCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DailyBriefSectionLabel(label: 'ACTIVE PROJECT'),
                        const SizedBox(height: AppSpacing.sm),
                        if (activeProject == null)
                          Text(
                            'No active projects. Start one from Projects.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.tertiary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  activeProject!.name,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (activeProject != null && onEnterToday != null)
                    IconButton(
                      onPressed: onEnterToday,
                      tooltip: 'Enter full system',
                      icon: Icon(
                        Icons.open_in_new,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              if (activeProject != null) ...[
                const SizedBox(height: AppSpacing.md),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'NEXT ACTION',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  nextAction ?? 'Define the next action for this project.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DailyBriefYesterdayStrip(summary: yesterday),
      ],
    );
  }
}
