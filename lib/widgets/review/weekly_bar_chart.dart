import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.dailyRates,
    required this.todayIndex,
  });

  final List<double> dailyRates;
  final int todayIndex;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _chartHeight = 160.0;
  static const _maxBarWidth = 40.0;

  int? _lowestWeekdayIndex() {
    int? lowestIndex;
    var lowestRate = double.infinity;
    for (var i = 0; i < 5; i++) {
      if (dailyRates[i] < lowestRate) {
        lowestRate = dailyRates[i];
        lowestIndex = i;
      }
    }
    return lowestIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lowestWeekday = _lowestWeekdayIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DAILY FOCUS DISTRIBUTION (HRS)',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BarColumn(
                    rate: dailyRates[i],
                    isWeekend: i >= 5,
                    isLowWeekday: lowestWeekday == i,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _dayLabels[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: i >= 5
                        ? colorScheme.outline
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.rate,
    required this.isWeekend,
    required this.isLowWeekday,
    required this.colorScheme,
  });

  final double rate;
  final bool isWeekend;
  final bool isLowWeekday;
  final ColorScheme colorScheme;

  Color _fillColor() {
    if (isWeekend) {
      return colorScheme.outline;
    }
    if (isLowWeekday) {
      return colorScheme.tertiary;
    }
    return colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final clampedRate = rate.clamp(0.0, 1.0);
    final fillHeight = WeeklyBarChart._chartHeight * clampedRate;
    final fillColor = _fillColor();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: WeeklyBarChart._maxBarWidth,
            ),
            child: SizedBox(
              height: WeeklyBarChart._chartHeight,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: fillHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
