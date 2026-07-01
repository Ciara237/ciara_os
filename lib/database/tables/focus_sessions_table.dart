import 'package:drift/drift.dart';

import 'tasks_table.dart';

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().references(Tasks, #id)();

  DateTimeColumn get startedAt => dateTime()();

  /// Null while session is active (recoverable).
  DateTimeColumn get endedAt => dateTime().nullable()();

  IntColumn get durationSeconds =>
      integer().withDefault(const Constant(0))();

  TextColumn get focusQuality => text().nullable()();

  BoolColumn get goalReached =>
      boolean().withDefault(const Constant(false))();

  /// Accumulated seconds before current segment (for pause/recovery).
  IntColumn get pausedElapsedSeconds =>
      integer().withDefault(const Constant(0))();

  /// When non-null the session clock is running.
  DateTimeColumn get segmentStartedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
