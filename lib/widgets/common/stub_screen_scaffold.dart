import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';

class StubScreenScaffold extends StatelessWidget {
  const StubScreenScaffold({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SidebarScreenScaffold(
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
