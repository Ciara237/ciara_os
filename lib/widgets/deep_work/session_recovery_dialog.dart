import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:flutter/material.dart';

enum SessionRecoveryChoice { resume, discard }

Future<SessionRecoveryChoice?> showSessionRecoveryDialog(
  BuildContext context, {
  required FocusSessionRecord session,
  required String taskTitle,
}) {
  return showDialog<SessionRecoveryChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      final elapsed = session.liveElapsedSeconds;

      return AlertDialog(
        title: Text(
          'Resume Focus Session?',
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskTitle,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'An active session was interrupted (${formatFocusClock(elapsed)} logged).',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, SessionRecoveryChoice.discard),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, SessionRecoveryChoice.resume),
            child: const Text('Resume'),
          ),
        ],
      );
    },
  );
}
