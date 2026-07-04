import 'package:drift/drift.dart';

class SecurityManualLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get platform => text()();

  TextColumn get activityType => text()();

  TextColumn get name => text()();

  TextColumn get difficulty => text().nullable()();

  DateTimeColumn get activityDate => dateTime()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get loggedAt => dateTime()();
}
