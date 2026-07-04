import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/router/app_router.dart';
import 'package:ciaraos/services/notification_service.dart';
import 'package:ciaraos/services/settings_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

Future<void> initializeNotificationService(WidgetRef ref) async {
  try {
    final service = ref.read(notificationServiceProvider);
    await service.initialize(
      onNotificationTap: (payload, channelId) async {
        if (channelId == 'deep_work' || isDeepWorkNotificationPayload(payload)) {
          final repo = ref.read(focusSessionRepositoryProvider);
          final today = DateTime.now();
          final completed =
              await repo.getCompletedSessionsForDay(today);
          final active = await repo.getActiveSession();
          if (completed.isNotEmpty || active != null) {
            return;
          }
        }

        final route = notificationRouteFromPayload(payload);
        if (route != null) {
          ref.read(routerProvider).go(route);
        }
      },
    );

    await restoreNotificationsFromPreferences(ref);
  } catch (error, stackTrace) {
    debugPrint('NotificationService init skipped: $error');
    debugPrint('$stackTrace');
  }
}

Future<bool> notificationsMasterEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(notificationsMasterPreferenceKey) ??
      prefs.getBool(notificationsEnabledPreferenceKey) ??
      false;
}

Future<bool> deadlineRemindersEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  final master = await notificationsMasterEnabled();
  return master && (prefs.getBool(deadlineRemindersPreferenceKey) ?? true);
}

Future<void> restoreNotificationsFromPreferences(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final master = await notificationsMasterEnabled();
  final deadlinesEnabled = master &&
      (prefs.getBool(deadlineRemindersPreferenceKey) ?? true);
  final dailyBriefTime = parseNotificationTime(
    prefs.getString(dailyBriefTimePreferenceKey) ?? defaultDailyBriefTime,
  );
  final deepWorkTime = parseNotificationTime(
    prefs.getString(deepWorkNudgeTimePreferenceKey) ??
        defaultDeepWorkNudgeTime,
  );

  final deadlineItems = <({int id, String title, String type, DateTime deadline})>[];
  if (deadlinesEnabled) {
    final tasks = ref.read(allTasksProvider).value ?? const <Task>[];
    for (final task in tasks) {
      final deadline = task.deadline;
      if (deadline != null) {
        deadlineItems.add(
          (
            id: task.id,
            title: task.title,
            type: 'task',
            deadline: deadline,
          ),
        );
      }
    }

    final opportunities =
        ref.read(allOpportunitiesProvider).value ?? const <Opportunity>[];
    for (final opportunity in opportunities) {
      final deadline = opportunity.deadline;
      if (deadline != null) {
        deadlineItems.add(
          (
            id: opportunity.id,
            title: opportunity.title,
            type: 'opportunity',
            deadline: deadline,
          ),
        );
      }
    }
  }

  await ref.read(notificationServiceProvider).restoreFromPreferences(
        masterEnabled: master,
        deadlineRemindersEnabled: deadlinesEnabled,
        dailyBriefTime: dailyBriefTime,
        deepWorkTime: deepWorkTime,
        deadlines: deadlineItems,
      );
}

Future<void> scheduleDeadlineIfEnabled(
  WidgetRef ref, {
  required int id,
  required String title,
  required String type,
  required DateTime? deadline,
}) async {
  final service = ref.read(notificationServiceProvider);
  if (!await deadlineRemindersEnabled()) {
    await service.cancelDeadlineReminders(id, type: type);
    return;
  }

  if (deadline == null) {
    await service.cancelDeadlineReminders(id, type: type);
    return;
  }

  await service.scheduleDeadlineReminders(
    id: id,
    title: title,
    type: type,
    deadline: deadline,
  );
}

Future<void> cancelAllNotifications(WidgetRef ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.cancelAllTrackedNotifications();
  await service.cancelDailyBrief();
  await service.cancelDeepWorkNudge();
}

Future<void> rescheduleAllDeadlineReminders(WidgetRef ref) async {
  if (!await deadlineRemindersEnabled()) {
    await ref.read(notificationServiceProvider).cancelAllDeadlineNotifications();
    return;
  }

  final tasks = ref.read(allTasksProvider).value ?? const <Task>[];
  for (final task in tasks) {
    await scheduleDeadlineIfEnabled(
      ref,
      id: task.id,
      title: task.title,
      type: 'task',
      deadline: task.deadline,
    );
  }

  final opportunities =
      ref.read(allOpportunitiesProvider).value ?? const <Opportunity>[];
  for (final opportunity in opportunities) {
    await scheduleDeadlineIfEnabled(
      ref,
      id: opportunity.id,
      title: opportunity.title,
      type: 'opportunity',
      deadline: opportunity.deadline,
    );
  }
}
