import 'package:ciaraos/models/certification.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/certification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final certificationRepositoryProvider =
    Provider<CertificationRepository>((ref) {
  return CertificationRepository(ref.watch(databaseProvider));
});

final allCertificationsProvider = StreamProvider<List<Certification>>((ref) {
  return ref.watch(certificationRepositoryProvider).watchAll();
});

final certificationsByStatusProvider =
    StreamProvider.family<List<Certification>, CertificationStatus>((ref, status) {
  return ref.watch(certificationRepositoryProvider).watchByStatus(status);
});
