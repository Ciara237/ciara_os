import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:ciaraos/widgets/deep_work/end_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepWorkCard extends ConsumerStatefulWidget {
  const DeepWorkCard({super.key});

  @override
  ConsumerState<DeepWorkCard> createState() => _DeepWorkCardState();
}

class _DeepWorkCardState extends ConsumerState<DeepWorkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _goalController;

  @override
  void initState() {
    super.initState();
    _goalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _endSession() async {
    final engine = ref.read(focusSessionProvider.notifier);
    final state = ref.read(focusSessionProvider);
    final session = state.session;
    if (session == null) {
      return;
    }

    final quality = await showEndSessionDialog(
      context,
      durationSeconds: state.totalElapsedSeconds,
    );
    if (quality == null || !mounted) {
      return;
    }

    await engine.endSession(quality);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(focusSessionProvider);

    if (!state.isActive) {
      return const SizedBox.shrink();
    }

    final taskAsync = ref.watch(taskByIdProvider(state.taskId!));
    final task = taskAsync.value;
    if (task == null) {
      return const SizedBox.shrink();
    }

    if (state.goalCelebrated && _goalController.status != AnimationStatus.completed) {
      _goalController.forward(from: 0);
    }

    final domainColor = context.domainColor(task.domain);
    final progress = state.goalProgress;
    final remaining = state.remainingToGoal;
    final sessionNum = currentSessionNumber(task, isActiveForTask: true);
    final planned = plannedSessionCount(task);
    final streakAsync = ref.watch(todayPerformanceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.goalReached)
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _goalController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'GOAL ACHIEVED',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulsingDot(color: colorScheme.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        state.isRunning ? 'ACTIVE SESSION' : 'PAUSED',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              streakAsync.maybeWhen(
                data: (s) => Text(
                  '${s.dailyStreak}d streak',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: state.goalReached
                            ? colorScheme.tertiary
                            : colorScheme.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatFocusClock(remaining),
                          style: AppTypography.headingMedium.copyWith(
                            color: colorScheme.onSurface,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        Text(
                          state.goalReached ? 'BEYOND GOAL' : 'REMAINING',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: domainColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            domainLabel(task.domain),
                            style: AppTypography.labelSmall.copyWith(
                              color: domainColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'SESSION $sessionNum OF $planned',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _Metric(
                          label: 'GOAL',
                          value: formatEstimatedMinutes(
                            task.estimatedDurationMinutes ?? defaultEstimatedMinutes,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _Metric(
                          label: 'FOCUSED',
                          value: formatFocusClock(state.totalElapsedSeconds),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _Metric(
                          label: 'TOTAL',
                          value: formatDurationMinutes(task.totalFocusedSeconds),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final engine = ref.read(focusSessionProvider.notifier);
                    if (state.isRunning) {
                      await engine.pause();
                    } else {
                      await engine.resume();
                    }
                  },
                  icon: Icon(
                    state.isRunning ? Icons.pause : Icons.play_arrow,
                    size: AppSpacing.md,
                  ),
                  label: Text(
                    state.isRunning ? 'PAUSE' : 'RESUME',
                    style: AppTypography.labelLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _endSession,
                  icon: const Icon(Icons.stop, size: AppSpacing.md),
                  label: Text(
                    'END SESSION',
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
