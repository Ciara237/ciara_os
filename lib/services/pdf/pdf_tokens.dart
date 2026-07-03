import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// TODO: embed Inter + JetBrains Mono TTF files in Phase 2 for brand-accurate PDF typography

/// Resolved PDF colors for light or dark export.
final class PdfThemePalette {
  const PdfThemePalette({
    required this.bg,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceVariant,
    required this.primary,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.surfaceRowAlt,
    required this.divider,
    required this.footer,
    required this.summaryBg,
    required this.summaryBorder,
    required this.domainHeaderBg,
    required this.rowAlt,
  });

  final PdfColor bg;
  final PdfColor onSurface;
  final PdfColor onSurfaceMuted;
  final PdfColor onSurfaceVariant;
  final PdfColor primary;
  final PdfColor surfaceCard;
  final PdfColor surfaceElevated;
  final PdfColor surfaceRowAlt;
  final PdfColor divider;
  final PdfColor footer;
  final PdfColor summaryBg;
  final PdfColor summaryBorder;
  final PdfColor domainHeaderBg;
  final PdfColor rowAlt;

  static PdfThemePalette fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  static const dark = PdfThemePalette(
    bg: PdfColor.fromInt(0xFF081425),
    onSurface: PdfColor.fromInt(0xFFD8E3FB),
    onSurfaceMuted: PdfColor.fromInt(0xFF8E9197),
    onSurfaceVariant: PdfColor.fromInt(0xFFC5C6CD),
    primary: PdfColor.fromInt(0xFFB9C7E0),
    surfaceCard: PdfColor.fromInt(0xFF111C2D),
    surfaceElevated: PdfColor.fromInt(0xFF152031),
    surfaceRowAlt: PdfColor.fromInt(0xFF0D1829),
    divider: PdfColor.fromInt(0xFF2A3548),
    footer: PdfColor.fromInt(0xFF44474C),
    summaryBg: PdfColor.fromInt(0xFF111C2D),
    summaryBorder: PdfColor.fromInt(0xFF2A3548),
    domainHeaderBg: PdfColor.fromInt(0xFF152031),
    rowAlt: PdfColor.fromInt(0xFF0D1829),
  );

  static const light = PdfThemePalette(
    bg: PdfColor.fromInt(0xFFFFFFFF),
    onSurface: PdfColor.fromInt(0xFF0F172A),
    onSurfaceMuted: PdfColor.fromInt(0xFF64748B),
    onSurfaceVariant: PdfColor.fromInt(0xFF475569),
    primary: PdfColor.fromInt(0xFF3B82F6),
    surfaceCard: PdfColor.fromInt(0xFFF1F5F9),
    surfaceElevated: PdfColor.fromInt(0xFFF8FAFC),
    surfaceRowAlt: PdfColor.fromInt(0xFFF8FAFC),
    divider: PdfColor.fromInt(0xFFE2E8F0),
    footer: PdfColor.fromInt(0xFF64748B),
    summaryBg: PdfColor.fromInt(0xFFF1F5F9),
    summaryBorder: PdfColor.fromInt(0xFFE2E8F0),
    domainHeaderBg: PdfColor.fromInt(0xFFF8FAFC),
    rowAlt: PdfColor.fromInt(0xFFF8FAFC),
  );
}

/// Shared PDF typography and palette tokens (Stitch weekly debrief + task export).
abstract final class PdfTokens {
  static final bodyFont = pw.Font.helvetica();
  static final monoFont = pw.Font.courier();
  static final bodyBold = pw.Font.helveticaBold();
  static final monoBold = pw.Font.courierBold();

  // Semantic accents (Stitch domain + status colors)
  static const green = PdfColor.fromInt(0xFF10B981);
  static const red = PdfColor.fromInt(0xFFEF4444);
  static const blue = PdfColor.fromInt(0xFF3B82F6);
  static const amber = PdfColor.fromInt(0xFFF59E0B);
  static const purple = PdfColor.fromInt(0xFF8B5CF6);
  static const slate = PdfColor.fromInt(0xFF64748B);

  static const Map<Domain, PdfColor> domainAccent = {
    Domain.engineering: blue,
    Domain.security: red,
    Domain.opportunities: green,
    Domain.builder: purple,
    Domain.other: slate,
  };

  /// Built-in PDF fonts (Helvetica/Courier) are Latin-1 only.
  static String sanitize(String text) {
    return text
        .replaceAll('\u2014', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2022', '*')
        .replaceAll('\u00B7', ' | ')
        .replaceAll('\u25A1', '[]')
        .replaceAll('\u25B8', '>');
  }

  static PdfColor domainColor(Domain domain) =>
      domainAccent[domain] ?? slate;

  static PdfColor priorityColor(Priority priority) {
    return switch (priority) {
      Priority.low => slate,
      Priority.medium => blue,
      Priority.high => amber,
      Priority.critical => red,
    };
  }

  static PdfColor statusColor(TaskStatus status, {required PdfColor neutral}) {
    return switch (status) {
      TaskStatus.done => green,
      TaskStatus.inProgress => blue,
      TaskStatus.stuck => red,
      TaskStatus.notStarted => neutral,
    };
  }

  static String statusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.notStarted => 'NOT STARTED',
      TaskStatus.inProgress => 'IN PROGRESS',
      TaskStatus.done => 'DONE',
      TaskStatus.stuck => 'STUCK',
    };
  }

  static String priorityLabel(Priority priority) {
    return switch (priority) {
      Priority.low => 'LOW',
      Priority.medium => 'MEDIUM',
      Priority.high => 'HIGH',
      Priority.critical => 'CRITICAL',
    };
  }

  static pw.PageTheme pageTheme(PdfThemePalette palette) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      theme: pw.ThemeData.withFont(base: bodyFont, bold: bodyBold),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: palette.bg),
      ),
    );
  }
}
