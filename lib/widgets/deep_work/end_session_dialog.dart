import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:flutter/material.dart';

Future<FocusQuality?> showEndSessionDialog(
  BuildContext context, {
  required int durationSeconds,
}) {
  return showDialog<FocusQuality>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      FocusQuality? selected;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'End Focus Session',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Session duration: ${formatFocusClock(durationSeconds)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'How was your focus?',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final quality in FocusQuality.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(focusQualityLabel(quality)),
                      selected: selected == quality,
                      onSelected: (_) => setState(() => selected = quality),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.pop(dialogContext, selected),
                child: const Text('Complete Session'),
              ),
            ],
          );
        },
      );
    },
  );
}
