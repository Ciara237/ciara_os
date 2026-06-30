import 'dart:convert';

import 'package:ciaraos/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class WeeklyReview {
  const WeeklyReview({
    required this.id,
    required this.weekOf,
    this.whatWorked,
    this.whatFailed,
    this.whatToAutomate,
    this.whatToCut,
    this.nextActions = const [],
    this.startedRate,
    required this.totalTasks,
    required this.startedTasks,
    this.focusScore,
    required this.locked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final DateTime weekOf;
  final String? whatWorked;
  final String? whatFailed;
  final String? whatToAutomate;
  final String? whatToCut;
  final List<String> nextActions;
  final double? startedRate;
  final int totalTasks;
  final int startedTasks;
  final double? focusScore;
  final bool locked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WeeklyReview.fromRow(db.WeeklyReview row) {
    return WeeklyReview(
      id: row.id,
      weekOf: row.weekOf,
      whatWorked: row.whatWorked,
      whatFailed: row.whatFailed,
      whatToAutomate: row.whatToAutomate,
      whatToCut: row.whatToCut,
      nextActions: _nextActionsFromJson(row.nextActions),
      startedRate: row.startedRate,
      totalTasks: row.totalTasks,
      startedTasks: row.startedTasks,
      focusScore: row.focusScore,
      locked: row.locked,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static List<String> _nextActionsFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((action) => action as String).toList();
  }

  static String? _nextActionsToJson(List<String> actions) {
    if (actions.isEmpty) {
      return null;
    }

    return jsonEncode(actions);
  }

  db.WeeklyReviewsCompanion toCompanion({bool forInsert = false}) {
    return db.WeeklyReviewsCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      weekOf: Value(weekOf),
      whatWorked: Value(whatWorked),
      whatFailed: Value(whatFailed),
      whatToAutomate: Value(whatToAutomate),
      whatToCut: Value(whatToCut),
      nextActions: Value(_nextActionsToJson(nextActions)),
      startedRate: Value(startedRate),
      totalTasks: Value(totalTasks),
      startedTasks: Value(startedTasks),
      focusScore: Value(focusScore),
      locked: Value(locked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
