import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class DailyBriefCard extends StatelessWidget {
  const DailyBriefCard({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: borderColor == null
              ? null
              : Border(left: BorderSide(color: borderColor!, width: 4)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: borderColor == null ? 0 : AppSpacing.sm),
          child: child,
        ),
      ),
    );
  }
}

class DailyBriefSectionLabel extends StatelessWidget {
  const DailyBriefSectionLabel({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      style: AppTypography.labelLarge.copyWith(
        color: color ?? colorScheme.onSurfaceVariant,
        letterSpacing: 2,
        fontSize: 11,
      ),
    );
  }
}

class DailyBriefMetaChip extends StatelessWidget {
  const DailyBriefMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyBriefYesterdayStrip extends StatelessWidget {
  const DailyBriefYesterdayStrip({
    super.key,
    required this.summary,
    this.compact = false,
  });

  final YesterdaySummary summary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hoursLabel = summary.focusHours >= 1
        ? '${summary.focusHours.toStringAsFixed(1)}h Deep work'
        : '${(summary.focusHours * 60).round()}m Deep work';

    if (compact) {
      return DailyBriefCard(
        backgroundColor: colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 16, color: colorScheme.tertiary),
                const SizedBox(width: AppSpacing.xs),
                const DailyBriefSectionLabel(label: 'YESTERDAY'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _CompactStatRow(
              label: 'Productive Time',
              value: hoursLabel.replaceAll(' Deep work', ''),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CompactStatRow(
              label: 'Tasks Closed',
              value: '${summary.tasksCompleted}',
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DailyBriefSectionLabel(label: 'YESTERDAY SUMMARY'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _IconStat(
              icon: Icons.task_alt_outlined,
              label: '${summary.tasksCompleted} completed',
            ),
            Text('•', style: TextStyle(color: colorScheme.outlineVariant)),
            _IconStat(icon: Icons.timer_outlined, label: hoursLabel),
            Text('•', style: TextStyle(color: colorScheme.outlineVariant)),
            _IconStat(
              icon: Icons.psychology_outlined,
              label: '${summary.sessionCount} focused sessions',
            ),
          ],
        ),
      ],
    );
  }
}

class _IconStat extends StatelessWidget {
  const _IconStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CompactStatRow extends StatelessWidget {
  const _CompactStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DailyBriefPrimaryCta extends StatelessWidget {
  const DailyBriefPrimaryCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.showEnterHint = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool showEnterHint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onPrimary,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.arrow_forward, size: 18, color: colorScheme.onPrimary),
            ],
          ),
        ),
        if (showEnterHint) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Enter',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'to initiate session',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
