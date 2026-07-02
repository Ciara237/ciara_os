import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/resource.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/resource_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepository(ref.watch(databaseProvider));
});

final allResourcesProvider = StreamProvider<List<Resource>>((ref) {
  return ref.watch(resourceRepositoryProvider).watchAll();
});

final resourceSearchQueryProvider = StateProvider<String>((ref) => '');

final resourceTypeFilterProvider =
    StateProvider<ResourceType?>((ref) => null);

final resourceDomainFilterProvider = StateProvider<Domain?>((ref) => null);

final filteredResourcesProvider = Provider<AsyncValue<List<Resource>>>((ref) {
  final resourcesAsync = ref.watch(allResourcesProvider);
  final query = ref.watch(resourceSearchQueryProvider).trim().toLowerCase();
  final type = ref.watch(resourceTypeFilterProvider);
  final domain = ref.watch(resourceDomainFilterProvider);

  return resourcesAsync.whenData((resources) {
    var filtered = resources;
    if (type != null) {
      filtered = filtered.where((resource) => resource.type == type).toList();
    }
    if (domain != null) {
      filtered = filtered.where((resource) => resource.domain == domain).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (resource) =>
                resource.title.toLowerCase().contains(query) ||
                resource.url.toLowerCase().contains(query) ||
                (resource.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }
    return filtered;
  });
});
