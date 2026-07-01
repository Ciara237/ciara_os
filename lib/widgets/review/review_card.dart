import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Stitch `card-level-1` — surface-container-low with outline border.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.child,
    this.minHeight,
  });

  final Widget child;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: minHeight != null
          ? BoxConstraints(minHeight: minHeight!)
          : null,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
