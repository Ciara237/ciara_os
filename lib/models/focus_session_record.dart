import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:drift/drift.dart';

class FocusSessionRecord {
  const FocusSessionRecord({
    required this.id,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    this.focusQuality,
    required this.goalReached,
    required this.pausedElapsedSeconds,
    this.segmentStartedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int taskId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final FocusQuality? focusQuality;
  final bool goalReached;
  final int pausedElapsedSeconds;
  final DateTime? segmentStartedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => endedAt == null;

  bool get isRunning => segmentStartedAt != null;

  int get liveElapsedSeconds {
    if (segmentStartedAt == null) {
      return pausedElapsedSeconds;
    }
    return pausedElapsedSeconds +
        DateTime.now().difference(segmentStartedAt!).inSeconds;
  }

  factory FocusSessionRecord.fromRow(db.FocusSession row) {
    return FocusSessionRecord(
      id: row.id,
      taskId: row.taskId,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      durationSeconds: row.durationSeconds,
      focusQuality: row.focusQuality == null
          ? null
          : FocusQuality.values.byName(row.focusQuality!),
      goalReached: row.goalReached,
      pausedElapsedSeconds: row.pausedElapsedSeconds,
      segmentStartedAt: row.segmentStartedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.FocusSessionsCompanion toCompanion({bool forInsert = false}) {
    return db.FocusSessionsCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      taskId: Value(taskId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationSeconds: Value(durationSeconds),
      focusQuality: Value(focusQuality?.name),
      goalReached: Value(goalReached),
      pausedElapsedSeconds: Value(pausedElapsedSeconds),
      segmentStartedAt: Value(segmentStartedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  FocusSessionRecord copyWith({
    int? id,
    int? taskId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    FocusQuality? focusQuality,
    bool? goalReached,
    int? pausedElapsedSeconds,
    DateTime? segmentStartedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearEndedAt = false,
    bool clearFocusQuality = false,
    bool clearSegmentStartedAt = false,
  }) {
    return FocusSessionRecord(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      durationSeconds: durationSeconds ?? this.durationSeconds,
      focusQuality:
          clearFocusQuality ? null : (focusQuality ?? this.focusQuality),
      goalReached: goalReached ?? this.goalReached,
      pausedElapsedSeconds:
          pausedElapsedSeconds ?? this.pausedElapsedSeconds,
      segmentStartedAt: clearSegmentStartedAt
          ? null
          : (segmentStartedAt ?? this.segmentStartedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
