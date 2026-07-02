import 'package:ciaraos/models/planning_accuracy_data.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/analytics/accuracy_trend_chart.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanningAccuracyScreen extends ConsumerWidget {
  const PlanningAccuracyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(planningAccuracyProvider);

    return SidebarScreenScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          const _ScreenIntro(),
          const SizedBox(height: AppSpacing.lg),
          dataAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Could not load planning accuracy.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            data: (data) {
              if (!data.hasEnoughData) {
                return _EmptyState(taskCount: data.qualifyingTaskCount);
              }
              return _PlanningAccuracyBody(data: data);
            },
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANALYTICS',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Planning Accuracy',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Detailed analysis of estimated duration vs. actual execution reality.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.taskCount});

  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        taskCount == 0
            ? 'Not enough data yet. Complete more tasks with time estimates to see planning accuracy trends.'
            : 'Not enough data yet. Complete more tasks with time estimates to see planning accuracy trends. ($taskCount of 3 tasks logged.)',
        style: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PlanningAccuracyBody extends StatelessWidget {
  const _PlanningAccuracyBody({required this.data});

  final PlanningAccuracyData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OverallScoreCard(data: data),
        const SizedBox(height: AppSpacing.lg),
        _Card(
          child: AccuracyTrendChart(points: data.eightWeekTrend),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ByDomainCard(domains: data.byDomain),
        const SizedBox(height: AppSpacing.lg),
        _WorstEstimatesCard(misses: data.worstEstimates),
        if (data.tip != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _TipsCard(tip: data.tip!),
        ],
      ],
    );
  }
}

class _OverallScoreCard extends StatelessWidget {
  const _OverallScoreCard({required this.data});

  final PlanningAccuracyData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final delta = data.deltaVsPriorPeriod;
    final deltaPositive = delta != null && delta >= 0;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OVERALL ACCURACY',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPlanningAccuracy(data.overallAccuracy),
                style: AppTypography.displayLarge.copyWith(
                  color: colorScheme.primary,
                  fontSize: 56,
                  height: 1,
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        deltaPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formatAccuracyDelta(delta),
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.summaryText,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ByDomainCard extends StatelessWidget {
  const _ByDomainCard({required this.domains});

  final List<DomainAccuracy> domains;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCURACY BY DOMAIN',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (domains.isEmpty)
            Text(
              'No domain breakdown available.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...domains.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _DomainAccuracyRow(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class _DomainAccuracyRow extends StatelessWidget {
  const _DomainAccuracyRow({required this.entry});

  final DomainAccuracy entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[entry.domain]!;
    final overUnder = entry.avgOverUnderMinutes;
    final overUnderLabel = overUnder >= 0
        ? '+${overUnder.round()}m'
        : '${overUnder.round()}m';
    final overUnderColor = overUnder > 0
        ? colorScheme.error
        : overUnder < 0
            ? colorScheme.tertiary
            : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: domainColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  domainLabel(entry.domain),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: (entry.accuracyPercent / 100).clamp(0, 1),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 48,
          child: Text(
            overUnderLabel,
            textAlign: TextAlign.right,
            style: AppTypography.labelSmall.copyWith(color: overUnderColor),
          ),
        ),
      ],
    );
  }
}

class _WorstEstimatesCard extends StatelessWidget {
  const _WorstEstimatesCard({required this.misses});

  final List<TaskAccuracyMiss> misses;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOP 5 MISSES',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (misses.isEmpty)
            Text(
              'No estimate misses recorded yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...misses.map(
              (miss) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MissRow(miss: miss),
              ),
            ),
        ],
      ),
    );
  }
}

class _MissRow extends StatelessWidget {
  const _MissRow({required this.miss});

  final TaskAccuracyMiss miss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSevere = miss.gapMinutes.abs() >= miss.estimatedMinutes * 0.25;
    final borderColor =
        isSevere ? colorScheme.error : colorScheme.outlineVariant;
    final gapLabel = miss.gapPercent >= 0
        ? '+${miss.gapPercent.round()}%'
        : '${miss.gapPercent.round()}%';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSevere
            ? colorScheme.errorContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        border: Border(
          left: BorderSide(color: borderColor, width: 2),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  miss.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Est: ${formatMinutesLabel(miss.estimatedMinutes)} | Act: ${formatMinutesLabel(miss.actualMinutes)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            gapLabel,
            style: AppTypography.labelSmall.copyWith(
              color: isSevere ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibration Insights',
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tip,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.5,
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}
