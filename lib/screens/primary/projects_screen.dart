import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/common/empty_state.dart';
import 'package:ciaraos/widgets/projects/project_card.dart';
import 'package:ciaraos/widgets/projects/projects_screen_label.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  void _openNewProject(BuildContext context) {
    context.push('/projects/new');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsAsync = ref.watch(allProjectsProvider);
    final tasksAsync = ref.watch(allTasksProvider);

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                const ProjectsScreenLabel(),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openNewProject(context),
                    child: const Text('+ NEW PROJECT'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                projectsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => EmptyState(
                    message: 'Could not load projects.',
                    actionLabel: 'RETRY',
                    onAction: () => ref.invalidate(allProjectsProvider),
                  ),
                  data: (projects) {
                    final allTasks = tasksAsync.value ?? const [];
                    if (projects.isEmpty) {
                      return EmptyState(
                        style: EmptyStateStyle.projects,
                        title: 'No Active Projects',
                        message:
                            'The architecture is ready. Define your first '
                            'domain project to begin structured execution.',
                        actionLabel: 'INITIALIZE PROJECT',
                        actionIcon: Icons.add,
                        onAction: () => _openNewProject(context),
                      );
                    }

                    return Column(
                      children: [
                        for (var i = 0; i < projects.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          ProjectCard(
                            project: projects[i],
                            linkedTasks: allTasks,
                            onTap: () =>
                                context.push('/projects/${projects[i].id}'),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        _InitiateNewDomainCta(
                          onTap: () => _openNewProject(context),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InitiateNewDomainCta extends StatelessWidget {
  const _InitiateNewDomainCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: colorScheme.onSurfaceVariant,
              size: AppSpacing.xl,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'INITIATE NEW DOMAIN',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
