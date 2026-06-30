import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/screens/primary/today_screen.dart';
import 'package:ciaraos/screens/secondary/onboarding_screen.dart';
import 'package:ciaraos/screens/secondary/task_create_edit_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: onboarding,
    redirect: (context, state) {
      if (!onboarding.isLoaded) {
        return null;
      }

      final location = state.matchedLocation;
      final onOnboarding = location == '/onboarding';

      if (!onboarding.isComplete && !onOnboarding) {
        return '/onboarding';
      }
      if (onboarding.isComplete && onOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskCreateEditScreen(),
      ),
    ],
  );
});
