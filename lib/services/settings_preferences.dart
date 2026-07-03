import 'package:flutter/material.dart';

const notificationsEnabledPreferenceKey = 'notifications_enabled';
const notificationsMasterPreferenceKey = 'notifications_master';
const deadlineRemindersPreferenceKey = 'deadline_reminders';
const dailyBriefTimePreferenceKey = 'daily_brief_time';
const deepWorkNudgeTimePreferenceKey = 'deep_work_nudge_time';
const scheduledNotificationIdsPreferenceKey = 'scheduled_notification_ids';

const defaultDailyBriefTime = '07:30';
const defaultDeepWorkNudgeTime = '10:00';

TimeOfDay parseNotificationTime(String value, {String fallback = '07:30'}) {
  final parts = (value.isEmpty ? fallback : value).split(':');
  if (parts.length != 2) {
    return const TimeOfDay(hour: 7, minute: 30);
  }
  final hour = int.tryParse(parts[0]) ?? 7;
  final minute = int.tryParse(parts[1]) ?? 30;
  return TimeOfDay(hour: hour, minute: minute);
}

String formatNotificationTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String formatNotificationTimeDisplay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
