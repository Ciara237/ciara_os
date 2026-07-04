import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/security_activity.dart';
import 'package:drift/drift.dart';

class StoredSecurityManualLog {
  const StoredSecurityManualLog({
    required this.id,
    required this.platform,
    required this.activityType,
    required this.name,
    required this.activityDate,
    required this.loggedAt,
    this.difficulty,
    this.notes,
  });

  final int id;
  final String platform;
  final String activityType;
  final String name;
  final String? difficulty;
  final DateTime activityDate;
  final String? notes;
  final DateTime loggedAt;

  factory StoredSecurityManualLog.fromRow(db.SecurityManualLog row) {
    return StoredSecurityManualLog(
      id: row.id,
      platform: row.platform,
      activityType: row.activityType,
      name: row.name,
      difficulty: row.difficulty,
      activityDate: row.activityDate,
      notes: row.notes,
      loggedAt: row.loggedAt,
    );
  }

  db.SecurityManualLogsCompanion toCompanion() {
    return db.SecurityManualLogsCompanion(
      id: Value(id),
      platform: Value(platform),
      activityType: Value(activityType),
      name: Value(name),
      difficulty: Value(difficulty),
      activityDate: Value(activityDate),
      notes: Value(notes),
      loggedAt: Value(loggedAt),
    );
  }

  static db.SecurityManualLogsCompanion companionFromLog(
    SecurityManualLog log, {
    required DateTime activityDate,
    required DateTime loggedAt,
  }) {
    return db.SecurityManualLogsCompanion(
      platform: Value(log.platform),
      activityType: Value(log.activityType),
      name: Value(log.name),
      difficulty: Value(log.difficulty),
      activityDate: Value(activityDate),
      notes: Value(log.notes),
      loggedAt: Value(loggedAt),
    );
  }

  HackTheBoxActivity toHackTheBoxActivity() {
    return HackTheBoxActivity(
      name: name,
      type: activityType,
      difficulty: difficulty ?? 'Medium',
      points: 0,
      date: activityDate,
    );
  }

  HackerOneReport toHackerOneReport() {
    return HackerOneReport(
      title: name,
      program: 'Manual log',
      severity: _severityFromDifficulty(difficulty),
      status: activityType,
      date: activityDate,
    );
  }

  static String _severityFromDifficulty(String? difficulty) {
    return switch (difficulty?.toLowerCase()) {
      'critical' => 'critical',
      'high' => 'high',
      'medium' => 'medium',
      'low' => 'low',
      _ => 'info',
    };
  }
}

List<HackTheBoxActivity> mergeHackTheBoxActivity({
  required List<HackTheBoxActivity> synced,
  required List<StoredSecurityManualLog> manual,
}) {
  final merged = [
    ...synced,
    ...manual.map((log) => log.toHackTheBoxActivity()),
  ];
  merged.sort((a, b) => b.date.compareTo(a.date));
  return merged;
}

List<HackerOneReport> mergeHackerOneReports({
  required List<HackerOneReport> synced,
  required List<StoredSecurityManualLog> manual,
}) {
  final merged = [
    ...synced,
    ...manual.map((log) => log.toHackerOneReport()),
  ];
  merged.sort((a, b) => b.date.compareTo(a.date));
  return merged;
}
