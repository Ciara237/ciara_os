import 'package:ciaraos/providers/daily_brief_gate_provider.dart';
import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/screens/secondary/daily_brief_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen mandatory morning brief above the router (not a route transition).
class DailyBriefGateOverlay extends ConsumerWidget {
  const DailyBriefGateOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingNotifierProvider);
    final gate = ref.read(dailyBriefGateProvider);

    return ListenableBuilder(
      listenable: gate,
      builder: (context, _) {
        final showMandatoryBrief = onboarding.isComplete &&
            gate.isLoaded &&
            gate.shouldShowToday();

        if (!showMandatoryBrief) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            const DailyBriefScreen(),
          ],
        );
      },
    );
  }
}
