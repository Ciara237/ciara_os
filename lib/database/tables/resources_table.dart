import 'package:drift/drift.dart';

class Resources extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get url => text()();

  TextColumn get domain => text()();

  TextColumn get type => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
