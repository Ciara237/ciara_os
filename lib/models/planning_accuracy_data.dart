import 'package:ciaraos/models/enums/domain.dart';

class DomainAccuracy {
  const DomainAccuracy({
    required this.domain,
    required this.accuracyPercent,
    required this.avgOverUnderMinutes,
    required this.taskCount,
  });

  final Domain domain;
  final double accuracyPercent;
  final double avgOverUnderMinutes;
  final int taskCount;
}

class TaskAccuracyMiss {
  const TaskAccuracyMiss({
    required this.taskId,
    required this.title,
    required this.domain,
    required this.estimatedMinutes,
    required this.actualMinutes,
    required this.gapMinutes,
    required this.gapPercent,
    required this.planningAccuracy,
  });

  final int taskId;
  final String title;
  final Domain domain;
  final int estimatedMinutes;
  final int actualMinutes;
  final double gapMinutes;
  final double gapPercent;
  final double planningAccuracy;
}

class WeeklyAccuracyPoint {
  const WeeklyAccuracyPoint({
    required this.weekStart,
    required this.accuracy,
    required this.taskCount,
  });

  final DateTime weekStart;
  final double? accuracy;
  final int taskCount;
}

class PlanningAccuracyData {
  const PlanningAccuracyData({
    required this.overallAccuracy,
    required this.deltaVsPriorPeriod,
    required this.summaryText,
    required this.byDomain,
    required this.worstEstimates,
    required this.eightWeekTrend,
    this.tip,
    required this.qualifyingTaskCount,
    required this.hasEnoughData,
  });

  final double? overallAccuracy;
  final double? deltaVsPriorPeriod;
  final String summaryText;
  final List<DomainAccuracy> byDomain;
  final List<TaskAccuracyMiss> worstEstimates;
  final List<WeeklyAccuracyPoint> eightWeekTrend;
  final String? tip;
  final int qualifyingTaskCount;
  final bool hasEnoughData;
}
