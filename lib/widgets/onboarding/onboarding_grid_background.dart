import 'dart:ui';

import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Subtle engineering grid from Stitch welcome / system-ready screens.
class OnboardingGridBackground extends StatelessWidget {
  const OnboardingGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OnboardingGridPainter(
        lineColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
      ),
      size: Size.infinite,
    );
  }
}

class _OnboardingGridPainter extends CustomPainter {
  _OnboardingGridPainter({required this.lineColor});

  final Color lineColor;
  static const double _gridSize = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += _gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += _gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

/// Soft primary glow behind hero icons on welcome / system-ready steps.
class OnboardingAtmosphericGlow extends StatelessWidget {
  const OnboardingAtmosphericGlow({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Center(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
          child: Container(
            width: AppSpacing.containerMax * 0.5,
            height: AppSpacing.containerMax * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.12),
            ),
          ),
        ),
      ),
    );
  }
}
