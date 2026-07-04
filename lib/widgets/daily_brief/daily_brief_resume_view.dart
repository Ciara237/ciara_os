import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_chrome.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_shared.dart';
import 'package:flutter/material.dart';

class DailyBriefResumeView extends StatelessWidget {
  const DailyBriefResumeView({
    super.key,
    required this.greeting,
    required this.task,
    required this.elapsedSeconds,
    required this.activeProject,
    required this.yesterday,
    required this.queueTasks,
    required this.onResume,
    required this.onDiscard,
    required this.isBusy,
  });

  final String greeting;
  final Task? task;
  final int elapsedSeconds;
  final Project? activeProject;
  final YesterdaySummary yesterday;
  final List<Task> queueTasks;
  final VoidCallback? onResume;
  final VoidCallback? onDiscard;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >= dailyBriefWideBreakpoint;
    final domainColor =
        task == null ? colorScheme.primary : context.domainColor(task!.domain);
    final progress =
        (elapsedSeconds / deepWorkGoalSeconds).clamp(0.0, 1.0);

    final hero = DailyBriefCard(
      borderColor: domainColor,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pause_circle_filled,
                color: dailyBriefSessionAmber,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'SESSION INTERRUPTED',
                style: AppTypography.labelLarge.copyWith(
                  color: dailyBriefSessionAmber,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            task?.title ?? 'Unknown task',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your work was suspended mid-task. Resume now to maintain cognitive momentum.',
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        color: colorScheme.primary,
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ELAPSED',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      formatFocusClock(elapsedSeconds),
                      style: AppTypography.headingLarge.copyWith(
                        color: colorScheme.primary,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      'Goal: ${formatFocusClock(deepWorkGoalSeconds)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isWide) ...[
            const SizedBox(height: AppSpacing.lg),
            _ResumeActions(
              onResume: onResume,
              onDiscard: onDiscard,
              isBusy: isBusy,
            ),
          ],
        ],
      ),
    );

    final sideColumn = Column(
      children: [
        DailyBriefCard(
          backgroundColor: colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_tree_outlined,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  const DailyBriefSectionLabel(label: 'ACTIVE PROJECT'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                activeProject?.name ?? 'No active project',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (activeProject?.nextAction != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activeProject!.nextAction!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DailyBriefYesterdayStrip(summary: yesterday, compact: true),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          greeting,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Daily Brief',
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
            fontSize: 36,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: hero),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 4, child: sideColumn),
            ],
          )
        else ...[
          hero,
          const SizedBox(height: AppSpacing.md),
          sideColumn,
        ],
        if (isWide) ...[
          const SizedBox(height: AppSpacing.lg),
          _ResumeActions(
            onResume: onResume,
            onDiscard: onDiscard,
            isBusy: isBusy,
          ),
        ],
        if (queueTasks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _PipelineQueue(tasks: queueTasks),
        ],
      ],
    );
  }
}

class _ResumeActions extends StatelessWidget {
  const _ResumeActions({
    required this.onResume,
    required this.onDiscard,
    required this.isBusy,
  });

  final VoidCallback? onResume;
  final VoidCallback? onDiscard;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          onPressed: isBusy ? null : onResume,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('RESUME SESSION'),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: isBusy ? null : onDiscard,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: const Text('DISCARD SESSION'),
        ),
      ],
    );
  }
}

class _PipelineQueue extends StatelessWidget {
  const _PipelineQueue({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DailyBriefCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                DailyBriefSectionLabel(
                  label: 'PIPELINE QUEUE',
                  color: colorScheme.primary,
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.domainColor(task.domain),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'DOMAIN: ${domainLabel(task.domain)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
