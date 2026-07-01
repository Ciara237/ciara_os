import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:drift/drift.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.domain,
    required this.status,
    required this.priority,
    required this.started,
    required this.today,
    this.deadline,
    this.projectId,
    this.notes,
    required this.postponeCount,
    this.estimatedDurationMinutes,
    required this.totalFocusedSeconds,
    required this.focusSessionCount,
    this.planningAccuracy,
    this.lastFocusSessionAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final Domain domain;
  final TaskStatus status;
  final Priority priority;
  final bool started;
  final bool today;
  final DateTime? deadline;
  final int? projectId;
  final String? notes;
  final int postponeCount;
  final int? estimatedDurationMinutes;
  final int totalFocusedSeconds;
  final int focusSessionCount;
  final double? planningAccuracy;
  final DateTime? lastFocusSessionAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Task.fromRow(db.Task row) {
    return Task(
      id: row.id,
      title: row.title,
      domain: Domain.values.byName(row.domain),
      status: TaskStatus.values.byName(row.status),
      priority: Priority.values.byName(row.priority),
      started: row.started,
      today: row.today,
      deadline: row.deadline,
      projectId: row.projectId,
      notes: row.notes,
      postponeCount: row.postponeCount,
      estimatedDurationMinutes: row.estimatedDurationMinutes,
      totalFocusedSeconds: row.totalFocusedSeconds,
      focusSessionCount: row.focusSessionCount,
      planningAccuracy: row.planningAccuracy,
      lastFocusSessionAt: row.lastFocusSessionAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.TasksCompanion toCompanion({bool forInsert = false}) {
    return db.TasksCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      title: Value(title),
      domain: Value(domain.name),
      status: Value(status.name),
      priority: Value(priority.name),
      started: Value(started),
      today: Value(today),
      deadline: Value(deadline),
      projectId: Value(projectId),
      notes: Value(notes),
      postponeCount: Value(postponeCount),
      estimatedDurationMinutes: Value(estimatedDurationMinutes),
      totalFocusedSeconds: Value(totalFocusedSeconds),
      focusSessionCount: Value(focusSessionCount),
      planningAccuracy: Value(planningAccuracy),
      lastFocusSessionAt: Value(lastFocusSessionAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    Domain? domain,
    TaskStatus? status,
    Priority? priority,
    bool? started,
    bool? today,
    DateTime? deadline,
    int? projectId,
    String? notes,
    int? postponeCount,
    int? estimatedDurationMinutes,
    int? totalFocusedSeconds,
    int? focusSessionCount,
    double? planningAccuracy,
    DateTime? lastFocusSessionAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDeadline = false,
    bool clearProjectId = false,
    bool clearNotes = false,
    bool clearEstimatedDuration = false,
    bool clearPlanningAccuracy = false,
    bool clearLastFocusSessionAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      started: started ?? this.started,
      today: today ?? this.today,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      notes: clearNotes ? null : (notes ?? this.notes),
      postponeCount: postponeCount ?? this.postponeCount,
      estimatedDurationMinutes: clearEstimatedDuration
          ? null
          : (estimatedDurationMinutes ?? this.estimatedDurationMinutes),
      totalFocusedSeconds: totalFocusedSeconds ?? this.totalFocusedSeconds,
      focusSessionCount: focusSessionCount ?? this.focusSessionCount,
      planningAccuracy: clearPlanningAccuracy
          ? null
          : (planningAccuracy ?? this.planningAccuracy),
      lastFocusSessionAt: clearLastFocusSessionAt
          ? null
          : (lastFocusSessionAt ?? this.lastFocusSessionAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
