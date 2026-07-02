import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Header avatar — opens the drawer only. Never navigates away.
void handleAvatarNavigation(BuildContext context) {
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.hasDrawer ?? false) {
    scaffold!.openDrawer();
  }
}

/// Drawer avatar — closes drawer and returns to Today when not already there.
/// Does not touch focus session state.
void handleDrawerAvatarNavigation(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final navigator = Navigator.of(context);

  if (navigator.canPop()) {
    navigator.pop();
  }

  if (location != '/') {
    context.go('/');
  }
}
