import 'package:drift/drift.dart';

import 'projects_table.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get domain => text()();

  TextColumn get status =>
      text().withDefault(const Constant('notStarted'))();

  TextColumn get priority =>
      text().withDefault(const Constant('medium'))();

  BoolColumn get started => boolean().withDefault(const Constant(false))();

  BoolColumn get today => boolean().withDefault(const Constant(false))();

  DateTimeColumn get deadline => dateTime().nullable()();

  IntColumn get projectId =>
      integer().nullable().references(Projects, #id)();

  TextColumn get notes => text().nullable()();

  IntColumn get postponeCount =>
      integer().withDefault(const Constant(0))();

  /// Estimated focus time in minutes (planning).
  IntColumn get estimatedDurationMinutes => integer().nullable()();

  /// Sum of completed focus session durations.
  IntColumn get totalFocusedSeconds =>
      integer().withDefault(const Constant(0))();

  IntColumn get focusSessionCount =>
      integer().withDefault(const Constant(0))();

  /// 0–100 score after task completion (estimated vs actual focus).
  RealColumn get planningAccuracy => real().nullable()();

  DateTimeColumn get lastFocusSessionAt => dateTime().nullable()();

  /// Immutable completion timestamp — not bumped by later metadata edits.
  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
