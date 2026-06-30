import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/onboarding/onboarding_domain_card.dart';
import 'package:ciaraos/widgets/onboarding/onboarding_icon_container.dart';
import 'package:ciaraos/widgets/tasks/task_list_tile.dart';
import 'package:flutter/material.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OnboardingIconContainer(icon: Icons.terminal),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Welcome to Ciara OS',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'A personal execution system engineered specifically '
                  'for focused, high-fidelity workflows.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingDomainsStep extends StatelessWidget {
  const OnboardingDomainsStep({super.key});

  static const _domains = <({Domain domain, IconData icon, String description})>[
    (
      domain: Domain.engineering,
      icon: Icons.terminal,
      description:
          'Software development, coding projects, and technical skill building',
    ),
    (
      domain: Domain.security,
      icon: Icons.security,
      description:
          'CTF practice, vulnerability research, and cybersecurity skill development',
    ),
    (
      domain: Domain.opportunities,
      icon: Icons.trending_up,
      description:
          'Job applications, internships, fellowships, programs, and masters applications',
    ),
    (
      domain: Domain.builder,
      icon: Icons.construction,
      description:
          'Personal projects, portfolio work, and open source contributions',
    ),
    (
      domain: Domain.other,
      icon: Icons.more_horiz,
      description: "Admin tasks, learning, and anything that doesn't fit above",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final engineeringBlue = AppColors.domainColors[Domain.engineering]!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Text(
          'Domain Taxonomy',
          style: AppTypography.displayLarge.copyWith(
            color: engineeringBlue,
            fontSize: 32,
            height: 40 / 32,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Every task is classified into one of five domains. '
          'This color-coded architecture reduces cognitive load during '
          'execution, allowing rapid visual parsing of your workload distribution.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final entry in _domains) ...[
          OnboardingDomainCard(
            domain: entry.domain,
            icon: entry.icon,
            description: entry.description,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class OnboardingStartedHabitStep extends StatelessWidget {
  const OnboardingStartedHabitStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StartedHabitDemoCard(),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'The Started Habit.',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 32,
                    height: 40 / 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Logging active work immediately is the singular discipline '
                  'that separates intent from the reality of execution.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartedHabitDemoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 288,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'EXECUTION_MODE',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz,
                size: AppSpacing.md,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TaskListTile(task: TaskListTile.demoTask()),
          const SizedBox(height: AppSpacing.md),
          _StartedStateSegment(),
        ],
      ),
    );
  }
}

class _StartedStateSegment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Queued',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: AppSpacing.md,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: AppSpacing.md,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'STARTED',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSystemReadyStep extends StatelessWidget {
  const OnboardingSystemReadyStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OnboardingIconContainer(
                  icon: Icons.rocket_launch,
                  size: 80,
                  iconSize: 36,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'System Ready',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 32,
                    height: 40 / 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your execution environment is configured. Begin by '
                  'defining your first focused objective.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
