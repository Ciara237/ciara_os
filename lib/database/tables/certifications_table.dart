import 'package:drift/drift.dart';

class Certifications extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get issuer => text()();

  TextColumn get domain => text()();

  TextColumn get status => text()();

  DateTimeColumn get dateEarned => dateTime().nullable()();

  DateTimeColumn get targetDate => dateTime().nullable()();

  IntColumn get progressCurrent =>
      integer().withDefault(const Constant(0))();

  IntColumn get progressTotal => integer().withDefault(const Constant(0))();

  TextColumn get priority => text().nullable()();

  TextColumn get externalLink => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
