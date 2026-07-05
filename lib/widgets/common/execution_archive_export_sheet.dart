import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/csv_export_provider.dart';
import 'package:ciaraos/providers/pdf_export_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Shows the execution archive export bottom sheet.
Future<void> showExecutionArchiveExportSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => Theme(
      data: Theme.of(context),
      child: const _ExecutionArchiveExportSheet(),
    ),
  );
}

class _ExecutionArchiveExportSheet extends ConsumerStatefulWidget {
  const _ExecutionArchiveExportSheet();

  @override
  ConsumerState<_ExecutionArchiveExportSheet> createState() =>
      _ExecutionArchiveExportSheetState();
}

class _ExecutionArchiveExportSheetState
    extends ConsumerState<_ExecutionArchiveExportSheet> {
  String _selectedPeriod = 'month';
  DateTime? _customStart;
  DateTime? _customEnd;
  int? _loadingCard; // null, 0 for PDF, 1 for CSV

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(colorScheme),
              const SizedBox(height: AppSpacing.xl),
              _buildHeader(colorScheme),
              const SizedBox(height: AppSpacing.lg),
              _buildPeriodSelector(colorScheme),
              if (_selectedPeriod == 'custom') ...[
                const SizedBox(height: AppSpacing.md),
                _buildCustomDatePickers(colorScheme),
              ],
              const SizedBox(height: AppSpacing.lg),
              _buildExportCard(
                icon: Icons.picture_as_pdf,
                title: 'Export as PDF',
                subtitle: 'Achievement record · domain breakdown · accuracy analysis',
                cardIndex: 0,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildExportCard(
                icon: Icons.table_chart,
                title: 'Export as CSV',
                subtitle: 'Spreadsheet format · Excel / Google Sheets',
                cardIndex: 1,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _loadingCard != null ? null : () => Navigator.pop(context),
                child: Text(
                  'CANCEL OPERATION',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'EXPORT EXECUTION ARCHIVE',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 3.2,
            fontSize: 12,
          ),
        ),
        IconButton(
          onPressed: _loadingCard != null ? null : () => Navigator.pop(context),
          icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERIOD',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PeriodChip(
                label: 'This Week',
                selected: _selectedPeriod == 'week',
                onTap: () => setState(() => _selectedPeriod = 'week'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PeriodChip(
                label: 'This Month',
                selected: _selectedPeriod == 'month',
                onTap: () => setState(() => _selectedPeriod = 'month'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PeriodChip(
                label: 'All Time',
                selected: _selectedPeriod == 'all',
                onTap: () => setState(() => _selectedPeriod = 'all'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PeriodChip(
                label: 'Custom',
                selected: _selectedPeriod == 'custom',
                onTap: () => setState(() => _selectedPeriod = 'custom'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDatePickers(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _DatePickerField(
            label: 'From',
            date: _customStart,
            onPicked: (date) => setState(() => _customStart = date),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _DatePickerField(
            label: 'To',
            date: _customEnd,
            onPicked: (date) => setState(() => _customEnd = date),
          ),
        ),
      ],
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int cardIndex,
    required ColorScheme colorScheme,
  }) {
    final isLoading = _loadingCard == cardIndex;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: isLoading ? null : () => _handleExport(cardIndex),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Text('Generating...'),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headingLarge.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              height: 1.1,
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
                      ),
              ),
              if (!isLoading)
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(int cardIndex) async {
    setState(() => _loadingCard = cardIndex);

    try {
      final allTasks = ref.read(allTasksProvider).asData?.value ?? const <Task>[];
      final completedTasks = filterCompletedByPeriod(
        tasks: allTasks,
        period: _selectedPeriod,
        customStart: _customStart,
        customEnd: _customEnd,
      );

      if (cardIndex == 0) {
        await _exportPdf(completedTasks);
      } else {
        await _exportCsv(completedTasks);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCard = null);
      }
    }
  }

  Future<void> _exportPdf(List<Task> tasks) async {
    final periodLabel = _formatPeriodLabel();

    await ref.read(pdfExportServiceProvider).exportCompletedTasks(
          completedTasks: tasks,
          periodLabel: periodLabel,
          startDate: _customStart,
          endDate: _customEnd,
          brightness: Brightness.light, // Always use light theme for white background
        );
  }

  Future<void> _exportCsv(List<Task> tasks) async {
    final periodLabel = _formatPeriodLabel();

    await ref.read(csvExportServiceProvider).exportCompletedTasks(
          tasks: tasks,
          periodLabel: periodLabel,
        );
  }

  String _formatPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'this_week';
      case 'month':
        return 'this_month';
      case 'all':
        return 'all_time';
      case 'custom':
        if (_customStart != null && _customEnd != null) {
          return '${DateFormat('yyyyMMdd').format(_customStart!)}_${DateFormat('yyyyMMdd').format(_customEnd!)}';
        }
        return 'custom';
      default:
        return 'this_month';
    }
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: AppTypography.labelSmall.copyWith(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surfaceContainer,
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onPicked;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayDate = date == null
        ? 'Select date'
        : DateFormat('MMM d').format(date!);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: TextButton(
        onPressed: () => _pickDate(context),
        child: Text(
          displayDate,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}