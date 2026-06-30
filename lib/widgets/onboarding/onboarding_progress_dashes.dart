import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Four horizontal dashes — active = primary, inactive = surface variant.
class OnboardingProgressDashes extends StatelessWidget {
  const OnboardingProgressDashes({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              height: AppSpacing.xs,
              margin: EdgeInsets.only(
                right: index < totalSteps - 1 ? AppSpacing.sm : 0,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          );
        }),
      ),
    );
  }
}
