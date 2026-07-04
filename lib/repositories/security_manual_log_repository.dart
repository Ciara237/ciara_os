import 'package:ciaraos/database/app_database.dart' hide SecurityManualLog;
import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/models/stored_security_manual_log.dart';
import 'package:drift/drift.dart';

class SecurityManualLogRepository {
  SecurityManualLogRepository(this._db);

  final AppDatabase _db;

  Stream<List<StoredSecurityManualLog>> watchByPlatform(String platform) {
    final query = _db.select(_db.securityManualLogs)
      ..where((row) => row.platform.equals(platform))
      ..orderBy([(row) => OrderingTerm.desc(row.activityDate)]);

    return query.watch().map(
          (rows) => rows.map(StoredSecurityManualLog.fromRow).toList(),
        );
  }

  Future<int> insert(SecurityManualLog log) {
    final now = DateTime.now();
    final activityDate = log.date == null
        ? now
        : DateTime.tryParse(log.date!) ?? now;

    return _db.into(_db.securityManualLogs).insert(
          StoredSecurityManualLog.companionFromLog(
            log,
            activityDate: activityDate,
            loggedAt: now,
          ),
        );
  }
}
