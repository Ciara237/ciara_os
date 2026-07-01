import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ReviewScreenLabel extends StatelessWidget {
  const ReviewScreenLabel({
    super.key,
    required this.focusScorePercent,
    required this.deltaPercent,
    required this.hasPriorWeekData,
  });

  final int focusScorePercent;
  final double? deltaPercent;
  final bool hasPriorWeekData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deltaColor = !hasPriorWeekData
        ? colorScheme.onSurfaceVariant
        : (deltaPercent! > 0
            ? colorScheme.primary
            : deltaPercent! < 0
                ? colorScheme.error
                : colorScheme.onSurfaceVariant);

    final deltaText = !hasPriorWeekData
        ? '— vs last week'
        : '${deltaPercent! >= 0 ? '+' : ''}${deltaPercent!.toStringAsFixed(1)}% vs last week';

    final trendIcon = !hasPriorWeekData
        ? Icons.trending_flat
        : deltaPercent! > 0
            ? Icons.trending_up
            : deltaPercent! < 0
                ? Icons.trending_down
                : Icons.trending_flat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AGGREGATE EFFICIENCY',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$focusScorePercent%',
              style: AppTypography.displayLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  trendIcon,
                  size: AppSpacing.md,
                  color: deltaColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  deltaText,
                  style: AppTypography.bodyMedium.copyWith(color: deltaColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                height: AppSpacing.xs,
                child: LinearProgressIndicator(
                  value: focusScorePercent / 100,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
