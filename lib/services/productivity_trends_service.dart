import 'package:ciaraos/models/productivity_trends_data.dart';
import 'package:ciaraos/models/weekly_review.dart';

class ProductivityTrendsService {
  static const minWeeksForInsights = 4;
  static const _trendWeekCount = 8;

  ProductivityTrendsData compute({
    required List<WeeklyReview> reviews,
    required Map<DateTime, double> focusHoursByWeek,
  }) {
    final reviewCount = reviews.length;
    final weeks = _buildWeeks(
      reviews: reviews,
      focusHoursByWeek: focusHoursByWeek,
    );
    final scoredWeeks =
        weeks.where((week) => week.executionScore != null).toList();
    final startedWeeks =
        weeks.where((week) => week.startedRate != null).toList();
    final focusWeeks = weeks.where((week) => week.focusHours != null).toList();

    WeeklyTrendPoint? bestWeek;
    for (final week in scoredWeeks) {
      if (bestWeek == null ||
          week.executionScore! > bestWeek.executionScore!) {
        bestWeek = week;
      }
    }

    final avgStarted = startedWeeks.isEmpty
        ? null
        : startedWeeks
                .map((week) => week.startedRate!)
                .reduce((a, b) => a + b) /
            startedWeeks.length;

    final totalFocusHours = focusWeeks.isEmpty
        ? null
        : focusWeeks.map((week) => week.focusHours!).reduce((a, b) => a + b);

    final currentScore =
        scoredWeeks.isEmpty ? null : scoredWeeks.last.executionScore;
    final priorScore = scoredWeeks.length >= 2
        ? scoredWeeks[scoredWeeks.length - 2].executionScore
        : null;
    final delta = currentScore != null && priorScore != null
        ? currentScore - priorScore
        : null;

    return ProductivityTrendsData(
      weeks: weeks,
      reviewCount: reviewCount,
      hasEnoughData: reviewCount >= minWeeksForInsights,
      bestWeekLabel:
          bestWeek != null ? 'Week ${bestWeek.weekNumber}' : null,
      bestWeekScore: bestWeek?.executionScore,
      avgStartedRate: avgStarted,
      totalFocusHours: totalFocusHours,
      executionDelta: delta,
      currentExecutionScore: currentScore,
    );
  }

  List<WeeklyTrendPoint> _buildWeeks({
    required List<WeeklyReview> reviews,
    required Map<DateTime, double> focusHoursByWeek,
  }) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    final reviewByWeek = <DateTime, WeeklyReview>{};
    for (final review in reviews) {
      reviewByWeek[_startOfWeek(review.weekOf)] = review;
    }

    return List.generate(_trendWeekCount, (index) {
      final weeksAgo = _trendWeekCount - 1 - index;
      final weekStart = currentWeekStart.subtract(Duration(days: weeksAgo * 7));
      final review = reviewByWeek[weekStart];
      final focusHours = focusHoursByWeek[weekStart];

      return WeeklyTrendPoint(
        weekStart: weekStart,
        weekNumber: _isoWeekNumber(weekStart),
        executionScore: review?.executionScore,
        startedRate: review?.startedRate != null
            ? review!.startedRate! * 100
            : null,
        focusHours: focusHours != null && focusHours > 0 ? focusHours : null,
        hasReview: review != null,
      );
    });
  }

  static DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final yearStart = DateTime(thursday.year, 1, 1);
    return 1 + (thursday.difference(yearStart).inDays / 7).floor();
  }
}
