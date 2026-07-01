import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _focusGoalSeconds = 45 * 60;

class DeepFocusTimer extends ConsumerStatefulWidget {
  const DeepFocusTimer({super.key});

  @override
  ConsumerState<DeepFocusTimer> createState() => _DeepFocusTimerState();
}

class _DeepFocusTimerState extends ConsumerState<DeepFocusTimer> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void _toggleRunning() {
    final session = ref.read(focusSessionProvider);
    final focus = ref.read(focusSessionProvider.notifier);

    if (!session.isActive) {
      return;
    }

    if (session.isRunning) {
      focus.pause();
      _syncStartedFlag(session.taskId!, started: false);
      return;
    }

    focus.resume();
    _syncStartedFlag(session.taskId!, started: true);
  }

  void _reset() {
    final session = ref.read(focusSessionProvider);
    if (!session.isActive) {
      return;
    }

    ref.read(focusSessionProvider.notifier).reset();
    _syncStartedFlag(session.taskId!, started: false);
  }

  Future<void> _syncStartedFlag(int taskId, {required bool started}) async {
    final task = await ref.read(taskRepositoryProvider).getById(taskId);
    if (task == null || task.started == started) {
      return;
    }

    await ref.read(taskRepositoryProvider).update(
          task
              .copyWith(
                started: started,
                updatedAt: DateTime.now(),
              )
              .toCompanion(),
        );
    ref.invalidate(taskByIdProvider(taskId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = ref.watch(focusSessionProvider);
    final elapsed = session.totalElapsedSeconds;
    final formattedTime = formatFocusClock(elapsed);
    final progress = session.isActive
        ? (elapsed / _focusGoalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _expanded ? null : _toggleExpanded,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _expanded
                ? _ExpandedTimer(
                    key: const ValueKey('expanded'),
                    taskId: session.taskId,
                    formattedTime: formattedTime,
                    progress: progress,
                    running: session.isRunning,
                    hasSession: session.isActive,
                    onCollapse: _toggleExpanded,
                    onResume: _toggleRunning,
                    onReset: _reset,
                  )
                : _CollapsedTimer(
                    key: const ValueKey('collapsed'),
                    formattedTime: formattedTime,
                    hasSession: session.isActive,
                    running: session.isRunning,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedTimer extends StatelessWidget {
  const _CollapsedTimer({
    super.key,
    required this.formattedTime,
    required this.hasSession,
    required this.running,
  });

  final String formattedTime;
  final bool hasSession;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '⚡ DEEP FOCUS',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              hasSession
                  ? (running ? formattedTime : '$formattedTime · PAUSED')
                  : 'TAP TO EXPAND',
              style: AppTypography.labelSmall.copyWith(
                color: hasSession
                    ? colorScheme.primaryFixedDim
                    : colorScheme.onSurfaceVariant,
                fontFeatures: hasSession
                    ? const [FontFeature.tabularFigures()]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTimer extends ConsumerWidget {
  const _ExpandedTimer({
    super.key,
    required this.taskId,
    required this.formattedTime,
    required this.progress,
    required this.running,
    required this.hasSession,
    required this.onCollapse,
    required this.onResume,
    required this.onReset,
  });

  final int? taskId;
  final String formattedTime;
  final double progress;
  final bool running;
  final bool hasSession;
  final VoidCallback onCollapse;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskAsync = taskId != null
        ? ref.watch(taskByIdProvider(taskId!))
        : null;
    final taskTitle = taskAsync?.value?.title;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ DEEP FOCUS',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: onCollapse,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (taskTitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              taskTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            formattedTime,
            textAlign: TextAlign.center,
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 56 / 48,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasSession
                ? (running ? 'Focus session active' : 'Focus session paused')
                : 'Start a task to begin timing',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: hasSession ? progress : null,
            minHeight: AppSpacing.xs,
            backgroundColor: colorScheme.surfaceContainerLow,
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hasSession ? onResume : null,
                  child: Text(
                    running ? 'PAUSE' : 'RESUME',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: hasSession ? onReset : null,
                  child: Text(
                    'RESET',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
