import 'package:ciaraos/models/productivity_trends_data.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/analytics/inline_section_empty_state.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const kTrendsMinWeeks = 4;

enum _TrendsDataState { thresholdNotMet, partial, full }

_TrendsDataState _resolveTrendsState(int reviewCount) {
  if (reviewCount == 0) {
    return _TrendsDataState.thresholdNotMet;
  }
  if (reviewCount < kTrendsMinWeeks) {
    return _TrendsDataState.partial;
  }
  return _TrendsDataState.full;
}

class ProductivityTrendsScreen extends ConsumerWidget {
  const ProductivityTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(allWeeklyReviewsProvider);
    final trendsAsync = ref.watch(productivityTrendsProvider);

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
          reviewsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Could not load productivity trends.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            data: (reviews) {
              final reviewCount = reviews.length;
              final state = _resolveTrendsState(reviewCount);

              return trendsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Text(
                  'Could not load productivity trends.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                data: (data) => _TrendsBody(
                  data: data,
                  reviewCount: reviewCount,
                  state: state,
                ),
              );
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
          'Productivity Trends',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '8-week execution history from your weekly reviews.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendsBody extends StatelessWidget {
  const _TrendsBody({
    required this.data,
    required this.reviewCount,
    required this.state,
  });

  final ProductivityTrendsData data;
  final int reviewCount;
  final _TrendsDataState state;

  bool get _showFull => state == _TrendsDataState.full;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InsightsStrip(data: data, state: state, reviewCount: reviewCount),
        const SizedBox(height: AppSpacing.lg),
        _ExecutionScoreCard(
          data: data,
          reviewCount: reviewCount,
          state: state,
        ),
        const SizedBox(height: AppSpacing.lg),
        _StartedRateCard(
          data: data,
          reviewCount: reviewCount,
          state: state,
        ),
        const SizedBox(height: AppSpacing.lg),
        _FocusHoursCard(
          data: data,
          reviewCount: reviewCount,
          state: state,
        ),
        if (!_showFull) ...[
          const SizedBox(height: AppSpacing.lg),
          _ReviewUnlockCallout(
            reviewCount: reviewCount,
            state: state,
          ),
        ],
      ],
    );
  }
}

class _InsightsStrip extends StatelessWidget {
  const _InsightsStrip({
    required this.data,
    required this.state,
    required this.reviewCount,
  });

  final ProductivityTrendsData data;
  final _TrendsDataState state;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final locked = state == _TrendsDataState.thresholdNotMet;

    return Row(
      children: [
        Expanded(
          child: _InsightTile(
            label: 'Best Week',
            value: locked
                ? '—'
                : data.bestWeekLabel ?? '—',
            subtitle: locked
                ? null
                : data.bestWeekScore != null
                    ? '${data.bestWeekScore!.round()}% score'
                    : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _InsightTile(
            label: 'Avg Started Rate',
            value: locked
                ? '—'
                : data.avgStartedRate != null
                    ? '${data.avgStartedRate!.toStringAsFixed(1)}%'
                    : '—',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _InsightTile(
            label: 'Focus Hours',
            value: locked
                ? '—'
                : data.totalFocusHours != null
                    ? '${data.totalFocusHours!.toStringAsFixed(0)}h'
                    : '—',
            subtitle: locked ? null : 'this period',
          ),
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.primary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.tertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExecutionScoreCard extends StatelessWidget {
  const _ExecutionScoreCard({
    required this.data,
    required this.reviewCount,
    required this.state,
  });

  final ProductivityTrendsData data;
  final int reviewCount;
  final _TrendsDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showChart = state != _TrendsDataState.thresholdNotMet;

    return _TrendCard(
      title: 'Execution Score Trend',
      headerTrailing: showChart && data.currentExecutionScore != null
          ? '${data.currentExecutionScore!.round()}%'
          : '0.0%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!showChart)
            InlineSectionEmptyState(
              title: 'Locked',
              message:
                  'Execution score trends unlock after you complete weekly reviews.',
              actionHint: 'Finalize your Executive Debrief in the Review tab',
              progressCurrent: reviewCount,
              progressMax: kTrendsMinWeeks,
              progressUnit: 'reviews',
              icon: Icons.lock_outline,
            )
          else ...[
            SizedBox(
              height: 180,
              child: _LineTrendChart(
                values: data.weeks
                    .map((week) => week.executionScore)
                    .toList(),
                lineColor: colorScheme.primary,
                gridColor: colorScheme.outlineVariant,
              ),
            ),
            _WeekLabels(weeks: data.weeks),
            if (state == _TrendsDataState.partial)
              TrendBuildingNote(
                message:
                    'Building your trend… $reviewCount weeks tracked',
              ),
          ],
        ],
      ),
    );
  }
}

class _StartedRateCard extends StatelessWidget {
  const _StartedRateCard({
    required this.data,
    required this.reviewCount,
    required this.state,
  });

  final ProductivityTrendsData data;
  final int reviewCount;
  final _TrendsDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showChart = state != _TrendsDataState.thresholdNotMet;
    final current = data.weeks
        .where((week) => week.startedRate != null)
        .map((week) => week.startedRate!)
        .toList();

    return _TrendCard(
      title: 'Started Rate Trend',
      subtitle: 'Commitment vs. execution',
      child: showChart
          ? Column(
              children: [
                SizedBox(
                  height: 140,
                  child: _LineTrendChart(
                    values: data.weeks
                        .map((week) => week.startedRate)
                        .toList(),
                    lineColor: colorScheme.tertiary,
                    gridColor: colorScheme.outlineVariant,
                    benchmark: 70,
                    benchmarkColor: colorScheme.tertiary,
                  ),
                ),
                if (current.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${current.last.round()}%',
                        style: AppTypography.labelLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          : const ChartPlaceholder(
              overlayLabel: 'Awaiting data points',
              height: 140,
            ),
    );
  }
}

class _FocusHoursCard extends StatelessWidget {
  const _FocusHoursCard({
    required this.data,
    required this.reviewCount,
    required this.state,
  });

  final ProductivityTrendsData data;
  final int reviewCount;
  final _TrendsDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showChart = state != _TrendsDataState.thresholdNotMet;
    final focusWeeks = data.weeks
        .where((week) => week.focusHours != null && week.focusHours! > 0)
        .toList();
    final avgWeek = focusWeeks.isEmpty
        ? null
        : focusWeeks.map((week) => week.focusHours!).reduce((a, b) => a + b) /
            focusWeeks.length;

    return _TrendCard(
      title: 'Weekly Deep Work Focus',
      subtitle: 'Hours logged in flow state',
      headerTrailing: showChart && avgWeek != null
          ? '${avgWeek.toStringAsFixed(1)}h avg'
          : '--h',
      child: showChart
          ? SizedBox(
              height: 160,
              child: _BarTrendChart(
                values: data.weeks
                    .map((week) => week.focusHours ?? 0)
                    .toList(),
                barColor: colorScheme.primary,
                gridColor: colorScheme.outlineVariant,
                labels: data.weeks
                    .map((week) => 'W${week.weekNumber}')
                    .toList(),
              ),
            )
          : InlineSectionEmptyState(
              message:
                  'Focus hour trends appear once weekly reviews establish a baseline.',
              actionHint: 'Complete a weekly review with deep work logged',
              progressCurrent: reviewCount,
              progressMax: kTrendsMinWeeks,
              progressUnit: 'reviews',
              compact: true,
              icon: Icons.timer_outlined,
            ),
    );
  }
}

class _ReviewUnlockCallout extends StatelessWidget {
  const _ReviewUnlockCallout({
    required this.reviewCount,
    required this.state,
  });

  final int reviewCount;
  final _TrendsDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state == _TrendsDataState.thresholdNotMet
                ? 'Trends unlock after $kTrendsMinWeeks weekly reviews.'
                : 'Almost there — $reviewCount of $kTrendsMinWeeks reviews tracked.',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete your Executive Debrief in the Review tab each week. '
            'CIARA OS needs baseline historical data to generate accurate momentum projections.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onPrimaryContainer,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: (reviewCount / kTrendsMinWeeks).clamp(0, 1),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => context.go('/review'),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Go to Review'),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final String? headerTrailing;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (headerTrailing != null)
                Text(
                  headerTrailing!,
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _WeekLabels extends StatelessWidget {
  const _WeekLabels({required this.weeks});

  final List<WeeklyTrendPoint> weeks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < weeks.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'W${weeks[i].weekNumber}',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineTrendChart extends StatelessWidget {
  const _LineTrendChart({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    this.benchmark,
    this.benchmarkColor,
  });

  final List<double?> values;
  final Color lineColor;
  final Color gridColor;
  final double? benchmark;
  final Color? benchmarkColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineTrendPainter(
        values: values,
        lineColor: lineColor,
        gridColor: gridColor,
        benchmark: benchmark,
        benchmarkColor: benchmarkColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LineTrendPainter extends CustomPainter {
  _LineTrendPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    this.benchmark,
    this.benchmarkColor,
  });

  final List<double?> values;
  final Color lineColor;
  final Color gridColor;
  final double? benchmark;
  final Color? benchmarkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (benchmark != null) {
      final y = size.height - (benchmark! / 100) * size.height;
      final dashPaint = Paint()
        ..color = (benchmarkColor ?? gridColor).withValues(alpha: 0.6)
        ..strokeWidth = 1;
      const dash = 4.0;
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + dash, y), dashPaint);
        x += dash * 2;
      }
    }

    final path = Path();
    Offset? lastPoint;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        lastPoint = null;
        continue;
      }
      final x = values.length == 1
          ? size.width / 2
          : (size.width / (values.length - 1)) * i;
      final y = size.height - (value.clamp(0, 100) / 100) * size.height;
      final point = Offset(x, y);
      if (lastPoint == null) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      lastPoint = point;
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        continue;
      }
      final x = values.length == 1
          ? size.width / 2
          : (size.width / (values.length - 1)) * i;
      final y = size.height - (value.clamp(0, 100) / 100) * size.height;
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _LineTrendPainter oldDelegate) => true;
}

class _BarTrendChart extends StatelessWidget {
  const _BarTrendChart({
    required this.values,
    required this.barColor,
    required this.gridColor,
    required this.labels,
  });

  final List<double> values;
  final Color barColor;
  final Color gridColor;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxValue = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: maxValue == 0
                          ? 0
                          : (values[i] / maxValue).clamp(0.05, 1.0),
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: values[i] > 0
                              ? barColor.withValues(
                                  alpha: i == values.length - 1 ? 1 : 0.35,
                                )
                              : gridColor.withValues(alpha: 0.15),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  labels[i],
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
