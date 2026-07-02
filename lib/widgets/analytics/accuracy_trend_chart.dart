import 'package:ciaraos/models/planning_accuracy_data.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccuracyTrendChart extends StatelessWidget {
  const AccuracyTrendChart({
    super.key,
    required this.points,
  });

  final List<WeeklyAccuracyPoint> points;

  static const _chartHeight = 160.0;
  static const _benchmark = 80.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '8-WEEK TREND',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [
                _LegendDot(color: colorScheme.primary, label: 'ACCURACY'),
                const SizedBox(width: AppSpacing.md),
                _LegendLine(
                  color: colorScheme.outlineVariant,
                  label: '80% BENCHMARK',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: _chartHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _AccuracyTrendPainter(
              points: points,
              primaryColor: colorScheme.primary,
              gridColor: colorScheme.outlineVariant,
              benchmarkColor: colorScheme.outlineVariant,
              dotColor: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < points.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'WK ${(i + 1).toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 2, color: color.withValues(alpha: 0.5)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _AccuracyTrendPainter extends CustomPainter {
  _AccuracyTrendPainter({
    required this.points,
    required this.primaryColor,
    required this.gridColor,
    required this.benchmarkColor,
    required this.dotColor,
  });

  final List<WeeklyAccuracyPoint> points;
  final Color primaryColor;
  final Color gridColor;
  final Color benchmarkColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = gridColor.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      baselinePaint,
    );

    final benchmarkY = _yForAccuracy(AccuracyTrendChart._benchmark, size.height);
    final benchmarkPaint = Paint()
      ..color = benchmarkColor.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, benchmarkY),
        Offset(startX + dashWidth, benchmarkY),
        benchmarkPaint,
      );
      startX += dashWidth + dashSpace;
    }

    if (points.isEmpty) {
      return;
    }

    final path = Path();
    Offset? lastPoint;

    for (var i = 0; i < points.length; i++) {
      final accuracy = points[i].accuracy;
      if (accuracy == null) {
        lastPoint = null;
        continue;
      }

      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * i;
      final y = _yForAccuracy(accuracy, size.height);
      final point = Offset(x, y);

      if (lastPoint == null) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      lastPoint = point;
    }

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final accuracy = points[i].accuracy;
      if (accuracy == null) {
        continue;
      }
      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * i;
      final y = _yForAccuracy(accuracy, size.height);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = dotColor);
    }
  }

  double _yForAccuracy(double accuracy, double height) {
    final clamped = accuracy.clamp(0, 100);
    return height - (clamped / 100) * height;
  }

  @override
  bool shouldRepaint(covariant _AccuracyTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.primaryColor != primaryColor;
  }
}

String formatAccuracyDelta(double? delta) {
  if (delta == null) {
    return '—';
  }
  final sign = delta >= 0 ? '+' : '';
  return '$sign${delta.round()}%';
}

String formatMinutesLabel(int minutes) {
  if (minutes >= 60) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder > 0 ? '${hours}h ${remainder}m' : '${hours}h';
  }
  return '${minutes}m';
}

String weekRangeLabel(DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  final formatter = DateFormat('MMM d');
  return '${formatter.format(weekStart)} – ${formatter.format(end)}';
}
