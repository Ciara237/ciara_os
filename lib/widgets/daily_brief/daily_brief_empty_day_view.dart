import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_chrome.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_shared.dart';
import 'package:flutter/material.dart';

class DailyBriefEmptyDayView extends StatelessWidget {
  const DailyBriefEmptyDayView({
    super.key,
    required this.greeting,
    required this.onEnterToday,
    required this.weeklyFocusSeconds,
    required this.isBusy,
  });

  final String greeting;
  final VoidCallback? onEnterToday;
  final List<int> weeklyFocusSeconds;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >= dailyBriefWideBreakpoint;
    final todayIndex = todayWeekdayIndex(mondayOfWeek(DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          greeting,
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _EmptyMissionHero(onEnterToday: isBusy ? null : onEnterToday),
        const SizedBox(height: AppSpacing.xl),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _SuggestedActionsCard(
                  onEnterToday: onEnterToday,
                  isBusy: isBusy,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: _IdleStateCard()),
            ],
          )
        else ...[
          _SuggestedActionsCard(onEnterToday: onEnterToday, isBusy: isBusy),
          const SizedBox(height: AppSpacing.md),
          const _IdleStateCard(),
        ],
        const SizedBox(height: AppSpacing.xl),
        _WeeklyMomentumCard(
          weeklyFocusSeconds: weeklyFocusSeconds,
          todayIndex: todayIndex,
        ),
      ],
    );
  }
}

class _EmptyMissionHero extends StatelessWidget {
  const _EmptyMissionHero({required this.onEnterToday});

  final VoidCallback? onEnterToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DailyBriefSectionLabel(
                label: "TODAY'S MISSION",
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Nothing scheduled yet.',
                style: AppTypography.headingLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Let's decide what matters today.",
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onEnterToday,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('PLAN MY DAY'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
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

class _SuggestedActionsCard extends StatelessWidget {
  const _SuggestedActionsCard({
    required this.onEnterToday,
    required this.isBusy,
  });

  final VoidCallback? onEnterToday;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              const DailyBriefSectionLabel(label: 'SUGGESTED ACTIONS'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionTile(
            icon: Icons.edit_calendar_outlined,
            iconColor: colorScheme.primary,
            label: 'Plan Your Day',
            hint: 'Opens Today — use Backlog from there',
            onTap: isBusy ? null : onEnterToday,
          ),
          _ActionTile(
            icon: Icons.architecture_outlined,
            iconColor: colorScheme.tertiary,
            label: 'Continue a Project',
            hint: 'Opens Today — use Projects from there',
            onTap: isBusy ? null : onEnterToday,
          ),
          _ActionTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: colorScheme.secondary,
            label: 'Review Pipeline',
            hint: 'Opens Today — use Pipeline from there',
            onTap: isBusy ? null : onEnterToday,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.hint,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          hint!,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdleStateCard extends StatelessWidget {
  const _IdleStateCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Icon(
                  Icons.hourglass_empty,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'CURRENT SYSTEM STATE',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'IDLE',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyMomentumCard extends StatelessWidget {
  const _WeeklyMomentumCard({
    required this.weeklyFocusSeconds,
    required this.todayIndex,
  });

  final List<int> weeklyFocusSeconds;
  final int todayIndex;

  static const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxSeconds = weeklyFocusSeconds.fold<int>(
      1,
      (max, seconds) => seconds > max ? seconds : max,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Momentum',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your execution performance over the last 7 days.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final seconds = weeklyFocusSeconds[index];
                final fraction = seconds / maxSeconds;
                final isToday = index == todayIndex;
                final isFuture = index > todayIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      height: 120 * (isFuture ? 0.08 : fraction.clamp(0.08, 1.0)),
                      decoration: BoxDecoration(
                        color: isToday
                            ? colorScheme.primary.withValues(alpha: 0.2)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        border: isToday
                            ? Border(
                                top: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              )
                            : isFuture
                                ? Border(
                                    top: BorderSide(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(7, (index) {
              final isToday = index == todayIndex;
              return Expanded(
                child: Text(
                  isToday ? '${_dayLabels[index]} (NOW)' : _dayLabels[index],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: isToday
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 9,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
