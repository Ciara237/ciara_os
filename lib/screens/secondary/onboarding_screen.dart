import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/onboarding/onboarding_grid_background.dart';
import 'package:ciaraos/widgets/onboarding/onboarding_progress_dashes.dart';
import 'package:ciaraos/widgets/onboarding/onboarding_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipToToday() async {
    await ref.read(onboardingNotifierProvider).markComplete();
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _completeAndGo(String location) async {
    await ref.read(onboardingNotifierProvider).markComplete();
    if (mounted) {
      context.go(location);
    }
  }

  bool get _showsGrid => _currentPage == 0 || _currentPage == 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_showsGrid) const OnboardingGridBackground(),
          if (_showsGrid) const OnboardingAtmosphericGlow(),
          SafeArea(
            child: Column(
              children: [
                OnboardingProgressDashes(currentStep: _currentPage),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: const [
                      OnboardingWelcomeStep(),
                      OnboardingDomainsStep(),
                      OnboardingStartedHabitStep(),
                      OnboardingSystemReadyStep(),
                    ],
                  ),
                ),
                _OnboardingActions(
                  currentPage: _currentPage,
                  onSkip: _skipToToday,
                  onNext: () => _goToPage(_currentPage + 1),
                  onAcknowledge: () => _goToPage(2),
                  onInitializeSystem: () => _goToPage(3),
                  onCreateTask: () => _completeAndGo('/tasks/new'),
                  onEnterDashboard: () => _completeAndGo('/'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.currentPage,
    required this.onSkip,
    required this.onNext,
    required this.onAcknowledge,
    required this.onInitializeSystem,
    required this.onCreateTask,
    required this.onEnterDashboard,
  });

  final int currentPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onAcknowledge;
  final VoidCallback onInitializeSystem;
  final VoidCallback onCreateTask;
  final VoidCallback onEnterDashboard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: switch (currentPage) {
        0 => Column(
            children: [
              OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  foregroundColor: colorScheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text(
                  'Skip Intro',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Step',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.arrow_forward,
                      size: AppSpacing.md,
                      color: colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        1 => Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onAcknowledge,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Acknowledge Protocol',
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.arrow_forward,
                    size: AppSpacing.md,
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        2 => SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onInitializeSystem,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Initialize System',
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        _ => Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onCreateTask,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Initialize Your First Task',
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.arrow_forward,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: onEnterDashboard,
                child: Text(
                  'Enter Dashboard (Empty State)',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      },
    );
  }
}
