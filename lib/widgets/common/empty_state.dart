import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum EmptyStateStyle {
  /// Simple circle icon — errors, filtered lists, generic fallbacks.
  compact,

  /// Tasks backlog empty — glow + line-art anchor, filled CTA.
  tasks,

  /// Opportunities pipeline empty — boxed icon, system badge.
  pipeline,

  /// Projects empty — hero icon with glow, filled CTA.
  projects,
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.icon = Icons.auto_awesome_outlined,
    this.style = EmptyStateStyle.compact,
    this.footer,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final IconData icon;
  final EmptyStateStyle style;
  final Widget? footer;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFeatured = style != EmptyStateStyle.compact;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isFeatured ? AppSpacing.xxl * 2 : AppSpacing.xxl,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmptyStateVisual(
            style: style,
            icon: icon,
            colorScheme: colorScheme,
          ),
          SizedBox(height: isFeatured ? AppSpacing.lg : AppSpacing.lg),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: AppTypography.headingLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: (isFeatured
                    ? AppTypography.bodyLarge
                    : AppTypography.bodyLarge)
                .copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: isFeatured ? AppSpacing.xl : AppSpacing.lg),
            if (isFeatured)
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(
                  actionIcon ?? Icons.add,
                  size: AppSpacing.lg,
                ),
                label: Text(actionLabel!),
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
              )
            else
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onSecondaryAction,
              icon: Icon(
                Icons.menu_book_outlined,
                size: AppSpacing.md,
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                secondaryActionLabel!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: isFeatured ? AppSpacing.xl : AppSpacing.lg),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _EmptyStateVisual extends StatelessWidget {
  const _EmptyStateVisual({
    required this.style,
    required this.icon,
    required this.colorScheme,
  });

  final EmptyStateStyle style;
  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      EmptyStateStyle.compact => _CompactIcon(icon: icon, colorScheme: colorScheme),
      EmptyStateStyle.tasks => _TasksVisual(colorScheme: colorScheme),
      EmptyStateStyle.pipeline => _PipelineVisual(colorScheme: colorScheme),
      EmptyStateStyle.projects => _ProjectsVisual(colorScheme: colorScheme),
    };
  }
}

class _CompactIcon extends StatelessWidget {
  const _CompactIcon({
    required this.icon,
    required this.colorScheme,
  });

  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: AppSpacing.xxl,
        color: colorScheme.outline,
      ),
    );
  }
}

class _TasksVisual extends StatelessWidget {
  const _TasksVisual({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            Icons.attach_money,
            size: 120,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _PipelineVisual extends StatelessWidget {
  const _PipelineVisual({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        Icons.rocket_launch_outlined,
        size: AppSpacing.xxl + AppSpacing.md,
        color: colorScheme.primary.withValues(alpha: 0.8),
      ),
    );
  }
}

class _ProjectsVisual extends StatelessWidget {
  const _ProjectsVisual({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.account_tree_outlined,
              size: 56,
              color: colorScheme.primary,
            ),
          ),
          Positioned(
            top: 0,
            right: 8,
            child: Container(
              width: AppSpacing.md,
              height: AppSpacing.md,
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.5),
                    blurRadius: 8,
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

/// Stitch tasks empty state footer — keyboard shortcut hint.
class TasksEmptyStateFooter extends StatelessWidget {
  const TasksEmptyStateFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Press',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            'C',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'to quick-add anywhere',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

/// Stitch pipeline empty state footer — system status badge.
class PipelineEmptyStateFooter extends StatelessWidget {
  const PipelineEmptyStateFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        'SYSTEM: IDLE',
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.outline,
        ),
      ),
    );
  }
}
