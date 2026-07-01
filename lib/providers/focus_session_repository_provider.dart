import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/focus_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final focusSessionRepositoryProvider = Provider<FocusSessionRepository>((ref) {
  return FocusSessionRepository(ref.watch(databaseProvider));
});
