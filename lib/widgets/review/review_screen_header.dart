import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ReviewScreenHeader extends StatelessWidget {
  const ReviewScreenHeader({
    super.key,
    required this.onExport,
    required this.onFinalize,
  });

  final VoidCallback onExport;
  final VoidCallback onFinalize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Review',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Reflection and system recalibration.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onExport,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(color: colorScheme.outlineVariant),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            'Export Report',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: onFinalize,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            'Finalize Review',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: titleSection),
          actions,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleSection,
        const SizedBox(height: AppSpacing.lg),
        actions,
      ],
    );
  }
}
