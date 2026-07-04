import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformanceSnapshotCard extends ConsumerWidget {
  const PerformanceSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final snapshotAsync = ref.watch(todayPerformanceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: snapshotAsync.when(
        loading: () => const _SnapshotGrid.loading(),
        error: (_, _) => const _SnapshotGrid.empty(),
        data: (snapshot) => _SnapshotGrid(snapshot: snapshot),
      ),
    );
  }
}

class _SnapshotGrid extends StatelessWidget {
  const _SnapshotGrid({required this.snapshot}) : loading = false, empty = false;

  const _SnapshotGrid.loading()
      : snapshot = null,
        loading = true,
        empty = false;

  const _SnapshotGrid.empty()
      : snapshot = null,
        loading = false,
        empty = true;

  final TodayPerformanceSnapshot? snapshot;
  final bool loading;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = snapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE SNAPSHOT',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.45,
          children: [
            _Tile(
              icon: Icons.task_alt,
              label: 'Completed',
              value: loading
                  ? '—'
                  : '${s?.completedToday ?? 0}/${s?.totalToday ?? 0}',
            ),
            _Tile(
              icon: Icons.timer,
              label: 'Deep work',
              value: loading
                  ? '—'
                  : formatFocusUptime(s?.focusSeconds ?? 0),
            ),
            _Tile(
              icon: Icons.bolt,
              label: 'Sessions',
              value: loading ? '—' : '${s?.sessionCountToday ?? 0}',
            ),
            _Tile(
              icon: Icons.psychology_outlined,
              label: 'Focus quality',
              value: loading
                  ? '—'
                  : formatAverageQuality(s?.averageQualityScore),
            ),
            _Tile(
              icon: Icons.track_changes,
              label: 'Accuracy',
              value: loading
                  ? '—'
                  : formatPlanningAccuracy(s?.planningAccuracy),
            ),
            _Tile(
              icon: Icons.local_fire_department,
              label: 'Streak',
              value: loading
                  ? '—'
                  : '${s?.dailyStreak ?? 0}d',
              iconColor: loading
                  ? null
                  : (s?.streakLoggedToday == true
                      ? colorScheme.tertiary
                      : colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSpacing.md,
                color: iconColor ?? colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
