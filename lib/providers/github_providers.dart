import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/services/github_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubServiceProvider = Provider<GitHubService>((ref) {
  return GitHubService();
});

final githubActivityProvider = NotifierProvider<GitHubActivityNotifier,
    AsyncValue<GitHubActivity?>>(
  GitHubActivityNotifier.new,
);

class GitHubActivityNotifier extends Notifier<AsyncValue<GitHubActivity?>> {
  @override
  AsyncValue<GitHubActivity?> build() {
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;
  bool _syncInProgress = false;

  Future<void> sync({bool force = false}) async {
    if (_syncInProgress) {
      return;
    }

    final previous = state.value;
    if (previous == null) {
      state = const AsyncValue.loading();
    }

    _syncInProgress = true;

    try {
      await ref.read(profileProvider.notifier).reload();
      final username = ref.read(profileProvider).githubUsername;

      final activity = await ref.read(githubServiceProvider).fetchActivity(
            username: username,
            force: force,
          );
      _lastSynced = DateTime.now();
      state = AsyncValue.data(activity);
    } on GitHubFetchException catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error.message, stackTrace);
      }
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      _syncInProgress = false;
    }
  }

  bool get shouldAutoSync {
    if (state.value == null) {
      return _lastSynced == null;
    }
    if (_lastSynced == null) {
      return true;
    }
    return DateTime.now().difference(_lastSynced!) >
        const Duration(hours: 2);
  }
}
