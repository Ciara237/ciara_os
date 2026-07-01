import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:ciaraos/widgets/review/review_screen_label.dart';
import 'package:ciaraos/widgets/review/weekly_bar_chart.dart';
import 'package:flutter/material.dart';

/// Stitch bento row: aggregate efficiency (4 cols) + daily chart (8 cols).
class ReviewPerformanceSection extends StatelessWidget {
  const ReviewPerformanceSection({
    super.key,
    required this.focusScorePercent,
    required this.deltaPercent,
    required this.hasPriorWeekData,
    required this.dailyRates,
    required this.todayIndex,
  });

  final int focusScorePercent;
  final double? deltaPercent;
  final bool hasPriorWeekData;
  final List<double> dailyRates;
  final int todayIndex;

  static const _wideBreakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final efficiencyCard = ReviewCard(
      minHeight: 200,
      child: ReviewScreenLabel(
        focusScorePercent: focusScorePercent,
        deltaPercent: deltaPercent,
        hasPriorWeekData: hasPriorWeekData,
      ),
    );

    final chartCard = ReviewCard(
      child: WeeklyBarChart(
        dailyRates: dailyRates,
        todayIndex: todayIndex,
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: efficiencyCard),
          const SizedBox(width: AppSpacing.lg),
          Expanded(flex: 8, child: chartCard),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        efficiencyCard,
        const SizedBox(height: AppSpacing.lg),
        chartCard,
      ],
    );
  }
}
