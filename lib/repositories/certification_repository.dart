import 'package:ciaraos/database/app_database.dart' hide Certification;
import 'package:ciaraos/models/certification.dart';
import 'package:drift/drift.dart';

class CertificationRepository {
  CertificationRepository(this._db);

  final AppDatabase _db;

  Stream<List<Certification>> watchAll() {
    final query = _db.select(_db.certifications)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Certification.fromRow).toList(),
        );
  }

  Stream<List<Certification>> watchByStatus(CertificationStatus status) {
    final query = _db.select(_db.certifications)
      ..where((row) => row.status.equals(status.name))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Certification.fromRow).toList(),
        );
  }

  Future<Certification?> getById(int id) async {
    final query = _db.select(_db.certifications)
      ..where((row) => row.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Certification.fromRow(row);
  }

  Future<int> insert(CertificationsCompanion companion) {
    return _db.into(_db.certifications).insert(companion);
  }

  Future<bool> update(CertificationsCompanion companion) {
    return _db.update(_db.certifications).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.certifications)..where((row) => row.id.equals(id)))
        .go();
  }
}
