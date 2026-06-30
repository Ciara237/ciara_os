import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/opportunity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(ref.watch(databaseProvider));
});

final allOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchAll();
});
