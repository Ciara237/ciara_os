import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class OnboardingDomainCard extends StatelessWidget {
  const OnboardingDomainCard({
    super.key,
    required this.domain,
    required this.icon,
    required this.description,
  });

  final Domain domain;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(domain);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: AppSpacing.domainBarWidth,
              decoration: BoxDecoration(
                color: domainColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: domainColor, size: AppSpacing.lg),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _domainLabel(domain),
                        style: AppTypography.labelLarge.copyWith(
                          color: domainColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _domainLabel(Domain domain) {
  return switch (domain) {
    Domain.engineering => 'ENGINEERING',
    Domain.security => 'SECURITY',
    Domain.opportunities => 'OPPORTUNITIES',
    Domain.builder => 'BUILDER',
    Domain.other => 'OTHER',
  };
}
