import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Rounded-square icon container used on welcome and system-ready steps.
class OnboardingIconContainer extends StatelessWidget {
  const OnboardingIconContainer({
    super.key,
    required this.icon,
    this.size = 128,
    this.iconSize = 64,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: colorScheme.primary,
      ),
    );
  }
}
