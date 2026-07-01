import 'package:drift/drift.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get domain => text()();

  TextColumn get status =>
      text().withDefault(const Constant('active'))();

  TextColumn get nextAction => text().nullable()();

  TextColumn get externalLink => text().nullable()();

  TextColumn get description => text().nullable()();

  /// Project horizon in days — used for milestone / time-remaining calculations.
  IntColumn get timeAllocationDays =>
      integer().withDefault(const Constant(30))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
