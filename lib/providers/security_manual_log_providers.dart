import 'package:ciaraos/models/stored_security_manual_log.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/security_manual_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final securityManualLogRepositoryProvider =
    Provider<SecurityManualLogRepository>((ref) {
  return SecurityManualLogRepository(ref.watch(databaseProvider));
});

final htbManualLogsProvider = StreamProvider<List<StoredSecurityManualLog>>(
  (ref) => ref.watch(securityManualLogRepositoryProvider).watchByPlatform('htb'),
);

final h1ManualLogsProvider = StreamProvider<List<StoredSecurityManualLog>>(
  (ref) => ref.watch(securityManualLogRepositoryProvider).watchByPlatform('h1'),
);
