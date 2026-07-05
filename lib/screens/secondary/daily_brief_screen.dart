import 'dart:async';

import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/daily_brief_gate_provider.dart';
import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/session_recovery_provider.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/services/day_execution_stats.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/services/project_next_action_service.dart';
import 'package:ciaraos/services/daily_brief_state_service.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_chrome.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_default_view.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_empty_day_view.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_resume_view.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_shared.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_welcome_back_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DailyBriefScreen extends ConsumerStatefulWidget {
  const DailyBriefScreen({super.key});

  @override
  ConsumerState<DailyBriefScreen> createState() => _DailyBriefScreenState();
}

class _DailyBriefScreenState extends ConsumerState<DailyBriefScreen> {
  DailyBriefState? _briefState;
  bool _isNavigating = false;
  bool _isResolving = true;
  bool _resolveFailed = false;
  Timer? _clockTimer;
  String _clockLabel = _formatClock(DateTime.now());

  YesterdaySummary? _yesterday;
  AbsenceStatus? _absenceStatus;
  Task? _topTask;
  Project? _activeProject;
  Task? _interruptedTask;
  int _interruptedElapsedSeconds = 0;
  List<Task> _allTasks = const [];
  List<Task> _todayTasks = const [];
  List<BufferTaskEntry> _bufferTasks = const [];
  List<int> _weeklyFocusSeconds = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _clockLabel = _formatClock(DateTime.now()));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveBriefState());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  static String _formatClock(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  Future<void> _resolveBriefState() async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      final projectRepo = ref.read(projectRepositoryProvider);
      final focusRepo = ref.read(focusSessionRepositoryProvider);
      final weekReviewRepo = ref.read(weeklyReviewRepositoryProvider);

      final todayTasks = await taskRepo.getToday();
      final allTasks = await taskRepo.getAll();
      final projects = await projectRepo.getAll();
      final weekReview =
          await weekReviewRepo.getByWeek(mondayOfWeek(DateTime.now()));
      final activeSession = await focusRepo.getActiveSession();
      final hasInterruptedSession = activeSession != null;
      final weekMonday = mondayOfWeek(DateTime.now());
      final weeklyFocus = await loadMergedFocusSecondsForWeek(
        weekMonday: weekMonday,
        focusRepo: focusRepo,
      );

      final lastOpenedAt = ref.read(dailyBriefGateProvider).readLastOpenedAt();

      final briefState = DailyBriefStateService().compute(
        todayTasks: todayTasks,
        hasInterruptedSession: hasInterruptedSession,
        lastOpenedAt: lastOpenedAt,
      );

      final yesterday = normalizeCalendarDay(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      final sessions =
          await focusRepo.getCompletedSessionsForDay(yesterday);
      final persistedYesterdayFocus =
          await DailyActivityStats.focusSecondsFor(yesterday);

      Task? interruptedTask;
      if (activeSession != null) {
        interruptedTask = await taskRepo.getById(activeSession.taskId);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _briefState = briefState;
        _isResolving = false;
        _resolveFailed = false;
        _yesterday = computeYesterdaySummary(
          allTasks: allTasks,
          sessions: sessions,
          persistedFocusSeconds: persistedYesterdayFocus,
          day: yesterday,
        );
        _absenceStatus = computeAbsenceStatus(
          allTasks: allTasks,
          projects: projects,
          weekReview: weekReview,
        );
        _topTask = topPriorityTask(todayTasks);
        _activeProject = topActiveProject(projects);
        _interruptedTask = interruptedTask;
        _interruptedElapsedSeconds = activeSession?.liveElapsedSeconds ?? 0;
        _allTasks = allTasks;
        _todayTasks = todayTasks;
        _bufferTasks = highPriorityBufferTasks(allTasks);
        _weeklyFocusSeconds = weeklyFocus;
      });
    } catch (error, stackTrace) {
      debugPrint('Daily brief failed to load: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolving = false;
        _resolveFailed = true;
        _briefState = DailyBriefState.dailyBrief;
      });
    }
  }

  String _greetingName() {
    final profile = ref.read(profileProvider);
    final name = profile.resolvedDisplayName;
    if (name == 'Your Name') {
      return 'Ciara';
    }
    return name.split(' ').first;
  }

  String _timeAwareGreeting() {
    final hour = DateTime.now().hour;
    final name = _greetingName();

    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name.';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name.';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good evening, $name.';
    }
    return 'Working late, $name.';
  }

  int _daysSinceLastOpen() {
    final lastOpened = ref.read(dailyBriefGateProvider).readLastOpenedAt();
    if (lastOpened == null) {
      return 0;
    }
    final hours = DateTime.now().difference(lastOpened).inHours;
    if (hours < 48) {
      return 0;
    }
    return (hours / 24).ceil();
  }

  ({String title, String body}) _welcomeRecommendation() {
    final status = _absenceStatus!;
    if (status.overdueTaskCount > 0 && status.mostOverdueTask != null) {
      return (
        title: status.mostOverdueTask!.title,
        body: 'Address overdue work first.',
      );
    }
    if (status.weeklyReviewPending) {
      return (
        title: 'Weekly review pending',
        body: 'Complete your weekly review.',
      );
    }
    if (status.topActiveProject != null) {
      final project = status.topActiveProject!;
      return (
        title: displayNextAction(project, _allTasks) ?? project.name,
        body: 'Continue active project work.',
      );
    }
    return (
      title: 'Re-engage with your system',
      body: 'Pick one priority and start.',
    );
  }

  Future<void> _exitBrief({bool discardSession = false}) async {
    if (_isNavigating) {
      return;
    }

    setState(() => _isNavigating = true);

    final gate = ref.read(dailyBriefGateProvider);

    try {
      if (discardSession) {
        await ref.read(focusSessionProvider.notifier).discardActiveSession();
      }

      if (!mounted) {
        return;
      }

      // Save daily brief shown date
      gate.dismissBriefSync();
      await gate.markShownToday();
      await gate.markOpenedNow();

      if (!mounted) {
        return;
      }

      // Navigate to Today screen
      context.go('/');
    } catch (error, stackTrace) {
      debugPrint('Daily brief exit failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _isNavigating = false);
        context.go('/');
      }
    }
  }

  Future<void> _reEngageFromWelcomeBack() {
    final status = _absenceStatus;
    if (status == null) {
      return _exitBrief();
    }
    return _exitBrief();
  }

  Future<void> _resumeInterruptedSession() async {
    ref.read(sessionRecoveryHandledProvider.notifier).state = true;
    await ref.read(focusSessionProvider.notifier).recoverSession();
    await _exitBrief();
  }

  bool get _useExpandedChrome {
    final state = _briefState;
    return state == DailyBriefState.resumeSession ||
        state == DailyBriefState.returningAfterAbsence ||
        state == DailyBriefState.emptyDay;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(allTasksProvider, (previous, next) {
      if (next.hasValue && !_isResolving && mounted) {
        _resolveBriefState();
      }
    });
    ref.listen(dailyStatsRevisionProvider, (previous, next) {
      if (previous != next && !_isResolving && mounted && _briefState != null) {
        _resolveBriefState();
      }
    });
    ref.listen(focusSessionProvider, (previous, next) {
      if (previous?.isActive != next.isActive &&
          !_isResolving &&
          mounted &&
          _briefState != null) {
        _resolveBriefState();
      }
    });

    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >= dailyBriefWideBreakpoint;
    final maxWidth = _briefState == DailyBriefState.dailyBrief && !isWide
        ? 640.0
        : (isWide ? 1200.0 : 640.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DailyBriefChrome(
              showSearch: false,
              showProfile: false,
              clockLabel: _useExpandedChrome ? null : _clockLabel,
            ),
            Expanded(
              child: _isResolving || _briefState == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: _resolveFailed
                              ? _buildResolveError(colorScheme)
                              : _buildBody(),
                        ),
                      ),
                    ),
            ),
            if (!_isResolving &&
                _briefState != null &&
                !_resolveFailed &&
                _briefState != DailyBriefState.emptyDay &&
                _briefState != DailyBriefState.returningAfterAbsence &&
                _briefState != DailyBriefState.resumeSession)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: _buildFooterActions(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolveError(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Could not load your brief',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Local data could not be read. You can retry or enter Today.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _isNavigating
              ? null
              : () {
                  setState(() {
                    _isResolving = true;
                    _resolveFailed = false;
                    _briefState = null;
                  });
                  _resolveBriefState();
                },
          child: const Text('Retry'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: _isNavigating ? null : () => _exitBrief(),
          child: const Text('Enter Today'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final yesterday = _yesterday;
    if (yesterday == null) {
      return const SizedBox.shrink();
    }

    return switch (_briefState!) {
      DailyBriefState.dailyBrief => DailyBriefDefaultView(
          greeting: _timeAwareGreeting(),
          topTask: _topTask,
          todayCount: tasksForPerformanceDay(_allTasks).length,
          activeProject: _activeProject,
          allTasks: _allTasks,
          yesterday: yesterday,
          onEnterToday: _isNavigating ? null : () => _exitBrief(),
        ),
      DailyBriefState.resumeSession => DailyBriefResumeView(
          greeting: _timeAwareGreeting(),
          task: _interruptedTask,
          elapsedSeconds: _interruptedElapsedSeconds,
          activeProject: _activeProject,
          yesterday: yesterday,
          queueTasks: _todayTasks
              .where((task) => task.id != _interruptedTask?.id)
              .take(4)
              .toList(),
          onResume: _isNavigating ? null : _resumeInterruptedSession,
          onDiscard: _isNavigating
              ? null
              : () => _exitBrief(discardSession: true),
          isBusy: _isNavigating,
        ),
      DailyBriefState.emptyDay => DailyBriefEmptyDayView(
          greeting: _timeAwareGreeting(),
          weeklyFocusSeconds: _weeklyFocusSeconds,
          isBusy: _isNavigating,
          onEnterToday: _isNavigating ? null : () => _exitBrief(),
        ),
      DailyBriefState.returningAfterAbsence => DailyBriefWelcomeBackView(
          name: _greetingName(),
          daysAway: _daysSinceLastOpen(),
          status: _absenceStatus!,
          recommendationTitle: _welcomeRecommendation().title,
          recommendationBody: _welcomeRecommendation().body,
          bufferTasks: _bufferTasks,
          incompleteCount: countIncompleteHighPriority(_allTasks),
          onReEngage:
              _isNavigating ? null : () => _reEngageFromWelcomeBack(),
          onEnterFullSystem: _isNavigating ? null : () => _exitBrief(),
          isBusy: _isNavigating,
        ),
    };
  }

  Widget _buildFooterActions() {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (!_isNavigating) {
            _exitBrief();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: DailyBriefPrimaryCta(
          label: 'ENTER EXECUTION MODE',
          enabled: !_isNavigating,
          showEnterHint: true,
          onPressed: _isNavigating ? null : () => _exitBrief(),
        ),
      ),
    );
  }
}
