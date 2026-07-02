import 'package:ciaraos/database/app_database.dart' hide Resource;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/resource.dart';
import 'package:drift/drift.dart';

class ResourceRepository {
  ResourceRepository(this._db);

  final AppDatabase _db;

  Stream<List<Resource>> watchAll() {
    final query = _db.select(_db.resources)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Resource.fromRow).toList(),
        );
  }

  Stream<List<Resource>> watchByDomain(Domain domain) {
    final query = _db.select(_db.resources)
      ..where((row) => row.domain.equals(domain.name))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Resource.fromRow).toList(),
        );
  }

  Stream<List<Resource>> watchByType(ResourceType type) {
    final query = _db.select(_db.resources)
      ..where((row) => row.type.equals(type.name))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Resource.fromRow).toList(),
        );
  }

  Future<Resource?> getById(int id) async {
    final query = _db.select(_db.resources)..where((row) => row.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Resource.fromRow(row);
  }

  Future<int> insert(ResourcesCompanion companion) {
    return _db.into(_db.resources).insert(companion);
  }

  Future<bool> update(ResourcesCompanion companion) {
    return _db.update(_db.resources).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.resources)..where((row) => row.id.equals(id))).go();
  }
}
