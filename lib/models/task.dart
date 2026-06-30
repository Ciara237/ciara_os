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
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDeadline = false,
    bool clearProjectId = false,
    bool clearNotes = false,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
