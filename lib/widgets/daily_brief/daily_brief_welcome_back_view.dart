import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_chrome.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_shared.dart';
import 'package:flutter/material.dart';

class DailyBriefWelcomeBackView extends StatelessWidget {
  const DailyBriefWelcomeBackView({
    super.key,
    required this.name,
    required this.daysAway,
    required this.status,
    required this.recommendationTitle,
    required this.recommendationBody,
    required this.bufferTasks,
    required this.incompleteCount,
    required this.onReEngage,
    required this.onEnterFullSystem,
    required this.isBusy,
  });

  final String name;
  final int daysAway;
  final AbsenceStatus status;
  final String recommendationTitle;
  final String recommendationBody;
  final List<BufferTaskEntry> bufferTasks;
  final int incompleteCount;
  final VoidCallback? onReEngage;
  final VoidCallback? onEnterFullSystem;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >= dailyBriefWideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'SYSTEM INITIALIZATION',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.primary.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Welcome back, $name.',
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
            fontSize: 40,
            height: 1.05,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "It's been $daysAway days.",
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (isWide)
          _WideBento(
            status: status,
            recommendationTitle: recommendationTitle,
            recommendationBody: recommendationBody,
            daysAway: daysAway,
            bufferTasks: bufferTasks,
            incompleteCount: incompleteCount,
            onReEngage: onReEngage,
            onEnterFullSystem: onEnterFullSystem,
            isBusy: isBusy,
          )
        else
          _NarrowStack(
            status: status,
            recommendationTitle: recommendationTitle,
            recommendationBody: recommendationBody,
            daysAway: daysAway,
            bufferTasks: bufferTasks,
            incompleteCount: incompleteCount,
            onReEngage: onReEngage,
            onEnterFullSystem: onEnterFullSystem,
            isBusy: isBusy,
          ),
      ],
    );
  }
}

class _WideBento extends StatelessWidget {
  const _WideBento({
    required this.status,
    required this.recommendationTitle,
    required this.recommendationBody,
    required this.daysAway,
    required this.bufferTasks,
    required this.incompleteCount,
    required this.onReEngage,
    required this.onEnterFullSystem,
    required this.isBusy,
  });

  final AbsenceStatus status;
  final String recommendationTitle;
  final String recommendationBody;
  final int daysAway;
  final List<BufferTaskEntry> bufferTasks;
  final int incompleteCount;
  final VoidCallback? onReEngage;
  final VoidCallback? onEnterFullSystem;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _StatusCard(status: status)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _RecommendationCard(
                title: recommendationTitle,
                body: recommendationBody,
                daysAway: daysAway,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _BufferCard(
                tasks: bufferTasks,
                incompleteCount: incompleteCount,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                children: [
                  _ReEngageCard(
                    recommendationTitle: recommendationTitle,
                    onTap: onReEngage,
                    isBusy: isBusy,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FullSystemAccessCard(
                    onTap: onEnterFullSystem,
                    isBusy: isBusy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NarrowStack extends StatelessWidget {
  const _NarrowStack({
    required this.status,
    required this.recommendationTitle,
    required this.recommendationBody,
    required this.daysAway,
    required this.bufferTasks,
    required this.incompleteCount,
    required this.onReEngage,
    required this.onEnterFullSystem,
    required this.isBusy,
  });

  final AbsenceStatus status;
  final String recommendationTitle;
  final String recommendationBody;
  final int daysAway;
  final List<BufferTaskEntry> bufferTasks;
  final int incompleteCount;
  final VoidCallback? onReEngage;
  final VoidCallback? onEnterFullSystem;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusCard(status: status),
        const SizedBox(height: AppSpacing.md),
        _RecommendationCard(
          title: recommendationTitle,
          body: recommendationBody,
          daysAway: daysAway,
        ),
        const SizedBox(height: AppSpacing.md),
        _BufferCard(tasks: bufferTasks, incompleteCount: incompleteCount),
        const SizedBox(height: AppSpacing.md),
        _ReEngageCard(
          recommendationTitle: recommendationTitle,
          onTap: onReEngage,
          isBusy: isBusy,
        ),
        const SizedBox(height: AppSpacing.md),
        _FullSystemAccessCard(onTap: onEnterFullSystem, isBusy: isBusy),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final AbsenceStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DailyBriefCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DailyBriefSectionLabel(
                  label: 'STATUS SINCE YOU LEFT',
                  color: colorScheme.primary,
                ),
              ),
              Icon(Icons.history, size: 18, color: colorScheme.primary.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatusMetricRow(
            label: 'Overdue tasks',
            value: '${status.overdueTaskCount}',
            accent: AppColors.darkError,
            valueColor: AppColors.darkError,
          ),
          _StatusMetricRow(
            label: 'Active projects',
            value: '${status.activeProjectCount}',
            accent: colorScheme.primary,
            valueColor: colorScheme.primary,
          ),
          _StatusMetricRow(
            label: 'Pending weekly review',
            value: status.weeklyReviewPending ? 'Yes' : 'No',
            accent: colorScheme.tertiary,
            valueColor: colorScheme.tertiary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Efficiency is doing things right; effectiveness is doing the right things.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMetricRow extends StatelessWidget {
  const _StatusMetricRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color accent;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(width: 4, height: 32, color: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.body,
    required this.daysAway,
  });

  final String title;
  final String body;
  final int daysAway;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DailyBriefCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DailyBriefSectionLabel(
                  label: 'RECOMMENDATION',
                  color: colorScheme.primary,
                ),
              ),
              Icon(Icons.lightbulb_outline,
                  size: 18, color: colorScheme.primary.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
            ),
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Last active: $daysAway days ago',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BufferCard extends StatelessWidget {
  const _BufferCard({
    required this.tasks,
    required this.incompleteCount,
  });

  final List<BufferTaskEntry> tasks;
  final int incompleteCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DailyBriefCard(
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DailyBriefSectionLabel(
                  label: 'HIGH PRIORITY BUFFER',
                  color: colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$incompleteCount incomplete',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (tasks.isEmpty)
            Text(
              'No urgent items in queue.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final entry in tasks) _BufferRow(entry: entry),
        ],
      ),
    );
  }
}

class _BufferRow extends StatelessWidget {
  const _BufferRow({required this.entry});

  final BufferTaskEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeLabel = labelForBadge(entry.badge);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
        border: Border(left: BorderSide(color: entry.accentColor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank,
              size: 16, color: colorScheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.task.title,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: entry.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: entry.accentColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              badgeLabel,
              style: AppTypography.labelSmall.copyWith(
                color: entry.accentColor,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReEngageCard extends StatelessWidget {
  const _ReEngageCard({
    required this.recommendationTitle,
    required this.onTap,
    required this.isBusy,
  });

  final String recommendationTitle;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, size: 28, color: colorScheme.onPrimaryContainer),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'RE-ENGAGE',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                recommendationTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullSystemAccessCard extends StatelessWidget {
  const _FullSystemAccessCard({
    required this.onTap,
    required this.isBusy,
  });

  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.grid_view, size: 28, color: colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'ENTER FULL SYSTEM',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Open Today with full navigation — Backlog, Projects, Pipeline, and Review.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
