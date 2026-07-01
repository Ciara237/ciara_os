import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/navigation_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/widgets/deep_work/session_recovery_dialog.dart';
import 'package:ciaraos/widgets/navigation/primary_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrimaryShellScaffold extends ConsumerStatefulWidget {
  const PrimaryShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static int tabIndexForLocation(String location) {
    if (location.startsWith('/tasks') && location != '/tasks') {
      return 1;
    }
    for (var i = 0; i < kPrimaryNavDestinations.length; i++) {
      final route = kPrimaryNavDestinations[i].route;
      if (route == '/' && location == '/') {
        return 0;
      }
      if (route != '/' && location.startsWith(route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  ConsumerState<PrimaryShellScaffold> createState() =>
      _PrimaryShellScaffoldState();
}

class _PrimaryShellScaffoldState extends ConsumerState<PrimaryShellScaffold> {
  bool _recoveryChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerSessionRecovery());
  }

  Future<void> _offerSessionRecovery() async {
    if (_recoveryChecked || !mounted) {
      return;
    }
    _recoveryChecked = true;

    final session =
        await ref.read(focusSessionRepositoryProvider).getActiveSession();
    if (session == null || !mounted) {
      return;
    }

    final task =
        await ref.read(taskRepositoryProvider).getById(session.taskId);
    if (!mounted) {
      return;
    }

    final choice = await showSessionRecoveryDialog(
      context,
      session: session,
      taskTitle: task?.title ?? 'Unknown task',
    );
    if (!mounted || choice == null) {
      return;
    }

    final engine = ref.read(focusSessionProvider.notifier);
    switch (choice) {
      case SessionRecoveryChoice.resume:
        await engine.recoverSession();
      case SessionRecoveryChoice.discard:
        await engine.discardActiveSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final tabIndex = PrimaryShellScaffold.tabIndexForLocation(location);

    if (ref.read(selectedTabProvider) != tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabProvider.notifier).state = tabIndex;
      });
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const PrimaryNavBar(),
    );
  }
}
