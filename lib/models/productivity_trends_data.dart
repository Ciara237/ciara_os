class WeeklyTrendPoint {
  const WeeklyTrendPoint({
    required this.weekStart,
    required this.weekNumber,
    this.executionScore,
    this.startedRate,
    this.focusHours,
    required this.hasReview,
  });

  final DateTime weekStart;
  final int weekNumber;
  final double? executionScore;
  final double? startedRate;
  final double? focusHours;
  final bool hasReview;
}

class ProductivityTrendsData {
  const ProductivityTrendsData({
    required this.weeks,
    required this.reviewCount,
    required this.hasEnoughData,
    this.bestWeekLabel,
    this.bestWeekScore,
    this.avgStartedRate,
    this.totalFocusHours,
    this.executionDelta,
    this.currentExecutionScore,
  });

  final List<WeeklyTrendPoint> weeks;
  final int reviewCount;
  final bool hasEnoughData;
  final String? bestWeekLabel;
  final double? bestWeekScore;
  final double? avgStartedRate;
  final double? totalFocusHours;
  final double? executionDelta;
  final double? currentExecutionScore;
}
