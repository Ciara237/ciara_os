import 'package:ciaraos/models/enums/domain.dart';

class DomainStats {
  const DomainStats({
    required this.domain,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.stuckTasks,
    required this.totalFocusedSeconds,
    required this.startedRate,
    this.mostPostponedTaskTitle,
    this.mostPostponedCount = 0,
    required this.sharePercent,
  });

  final Domain domain;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int stuckTasks;
  final int totalFocusedSeconds;
  final double startedRate;
  final String? mostPostponedTaskTitle;
  final int mostPostponedCount;
  final double sharePercent;

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

class DomainImbalanceAlert {
  const DomainImbalanceAlert({
    required this.domain,
    required this.message,
  });

  final Domain domain;
  final String message;
}

class DomainBreakdownData {
  const DomainBreakdownData({
    required this.period,
    required this.totalTasks,
    required this.distribution,
    required this.domainStats,
    required this.imbalanceAlerts,
  });

  final String period;
  final int totalTasks;
  final Map<Domain, double> distribution;
  final List<DomainStats> domainStats;
  final List<DomainImbalanceAlert> imbalanceAlerts;
}
