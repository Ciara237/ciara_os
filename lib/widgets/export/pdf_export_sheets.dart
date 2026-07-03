import 'package:ciaraos/widgets/export/export_bottom_sheet.dart';
import 'package:flutter/material.dart';

String _pdfSubtitle(Brightness brightness) {
  return brightness == Brightness.dark
      ? 'Dark theme · Matches your current appearance'
      : 'Light theme · Matches your current appearance';
}

/// Review screen export — PDF + CSV options.
Future<void> showReviewExportSheet({
  required BuildContext context,
  required Future<void> Function() onExportPdf,
  required Future<void> Function() onExportCsv,
}) {
  final brightness = Theme.of(context).brightness;

  return showCiaraExportSheet(
    context: context,
    options: [
      ExportOption(
        title: 'Export as PDF',
        subtitle: _pdfSubtitle(brightness),
        icon: Icons.description_outlined,
        onExport: onExportPdf,
      ),
      ExportOption(
        title: 'Export as CSV',
        subtitle: 'Spreadsheet format · Opens in Excel or Sheets',
        icon: Icons.grid_on_outlined,
        onExport: onExportCsv,
      ),
    ],
  );
}

/// Tasks backlog export — PDF + CSV options.
Future<void> showTasksExportSheet({
  required BuildContext context,
  required Future<void> Function() onExportPdf,
  required Future<void> Function() onExportCsv,
}) {
  final brightness = Theme.of(context).brightness;

  return showCiaraExportSheet(
    context: context,
    overline: 'EXPORT TASKS',
    options: [
      ExportOption(
        title: 'Export as PDF',
        subtitle: _pdfSubtitle(brightness),
        icon: Icons.description_outlined,
        onExport: onExportPdf,
      ),
      ExportOption(
        title: 'Export as CSV',
        subtitle: 'Spreadsheet format · Opens in Excel or Sheets',
        icon: Icons.grid_on_outlined,
        onExport: onExportCsv,
      ),
    ],
  );
}
