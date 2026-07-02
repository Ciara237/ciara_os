import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:drift/drift.dart';

enum CertificationStatus {
  earned,
  inProgress,
  planned,
}

enum CertificationPriority {
  low,
  medium,
  high,
}

class Certification {
  const Certification({
    required this.id,
    required this.name,
    required this.issuer,
    required this.domain,
    required this.status,
    this.dateEarned,
    this.targetDate,
    required this.progressCurrent,
    required this.progressTotal,
    this.priority,
    this.externalLink,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String issuer;
  final Domain domain;
  final CertificationStatus status;
  final DateTime? dateEarned;
  final DateTime? targetDate;
  final int progressCurrent;
  final int progressTotal;
  final CertificationPriority? priority;
  final String? externalLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  double? get progressFraction {
    if (progressTotal <= 0) {
      return null;
    }
    return (progressCurrent / progressTotal).clamp(0.0, 1.0);
  }

  factory Certification.fromRow(db.Certification row) {
    return Certification(
      id: row.id,
      name: row.name,
      issuer: row.issuer,
      domain: Domain.values.byName(row.domain),
      status: CertificationStatus.values.byName(row.status),
      dateEarned: row.dateEarned,
      targetDate: row.targetDate,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      priority: row.priority == null
          ? null
          : CertificationPriority.values.byName(row.priority!),
      externalLink: row.externalLink,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.CertificationsCompanion toCompanion({bool forInsert = false}) {
    return db.CertificationsCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      name: Value(name),
      issuer: Value(issuer),
      domain: Value(domain.name),
      status: Value(status.name),
      dateEarned: Value(dateEarned),
      targetDate: Value(targetDate),
      progressCurrent: Value(progressCurrent),
      progressTotal: Value(progressTotal),
      priority: Value(priority?.name),
      externalLink: Value(externalLink),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  Certification copyWith({
    int? id,
    String? name,
    String? issuer,
    Domain? domain,
    CertificationStatus? status,
    DateTime? dateEarned,
    DateTime? targetDate,
    int? progressCurrent,
    int? progressTotal,
    CertificationPriority? priority,
    String? externalLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDateEarned = false,
    bool clearTargetDate = false,
    bool clearPriority = false,
    bool clearExternalLink = false,
  }) {
    return Certification(
      id: id ?? this.id,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      dateEarned: clearDateEarned ? null : (dateEarned ?? this.dateEarned),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      priority: clearPriority ? null : (priority ?? this.priority),
      externalLink:
          clearExternalLink ? null : (externalLink ?? this.externalLink),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
