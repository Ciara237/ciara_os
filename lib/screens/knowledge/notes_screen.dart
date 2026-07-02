import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/note.dart';
import 'package:ciaraos/providers/note_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);
    final filteredAsync = ref.watch(filteredNotesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SidebarScreenScaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl * 2,
            ),
            children: [
              _ScreenIntro(notesAsync: notesAsync),
              const SizedBox(height: AppSpacing.lg),
              _SearchField(
                onChanged: (value) =>
                    ref.read(noteSearchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
              _DomainFilterRow(
                selected: ref.watch(noteDomainFilterProvider),
                onSelected: (domain) =>
                    ref.read(noteDomainFilterProvider.notifier).state = domain,
              ),
              const SizedBox(height: AppSpacing.lg),
              filteredAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Text(
                  'Could not load notes.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                data: (notes) {
                  if (notes.isEmpty) {
                    return const _EmptyState();
                  }
                  return Column(
                    children: notes
                        .map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _NoteCard(note: note),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: FloatingActionButton(
              onPressed: () => context.push('/knowledge/notes/new'),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro({required this.notesAsync});

  final AsyncValue<List<Note>> notesAsync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = notesAsync.maybeWhen(
      data: (notes) {
        final domains = notes.map((note) => note.domain).toSet().length;
        return '${notes.length} notes across $domains domains';
      },
      orElse: () => 'Capture thoughts across domains',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KNOWLEDGE',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Notes',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search knowledge base...',
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _DomainFilterRow extends StatelessWidget {
  const _DomainFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final Domain? selected;
  final ValueChanged<Domain?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              showCheckmark: false,
              labelStyle: AppTypography.labelSmall.copyWith(
                color: selected == null
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
          ...Domain.values.map(
            (domain) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(domainLabel(domain)),
                selected: selected == domain,
                onSelected: (_) => onSelected(domain),
                showCheckmark: false,
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: selected == domain
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                selectedColor: colorScheme.primaryContainer,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  const _NoteCard({required this.note});

  final Note note;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Remove "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(noteRepositoryProvider).delete(note.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[note.domain]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/knowledge/notes/${note.id}'),
        onLongPress: () => _confirmDelete(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: domainColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.radiusLg),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                      right: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        notePreview(note.content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: domainColor.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              domainLabel(note.domain),
                              style: AppTypography.labelSmall.copyWith(
                                color: domainColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d, yyyy')
                                .format(note.updatedAt)
                                .toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sticky_note_2_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No notes yet...',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start capturing your thoughts, code snippets, or system architecture plans.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
