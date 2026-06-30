import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:drift/drift.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.domain,
    required this.status,
    this.nextAction,
    this.externalLink,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final Domain domain;
  final ProjectStatus status;
  final String? nextAction;
  final String? externalLink;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Project.fromRow(db.Project row) {
    return Project(
      id: row.id,
      name: row.name,
      domain: Domain.values.byName(row.domain),
      status: ProjectStatus.values.byName(row.status),
      nextAction: row.nextAction,
      externalLink: row.externalLink,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.ProjectsCompanion toCompanion({bool forInsert = false}) {
    return db.ProjectsCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      name: Value(name),
      domain: Value(domain.name),
      status: Value(status.name),
      nextAction: Value(nextAction),
      externalLink: Value(externalLink),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  Project copyWith({
    int? id,
    String? name,
    Domain? domain,
    ProjectStatus? status,
    String? nextAction,
    String? externalLink,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNextAction = false,
    bool clearExternalLink = false,
    bool clearDescription = false,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      nextAction: clearNextAction ? null : (nextAction ?? this.nextAction),
      externalLink:
          clearExternalLink ? null : (externalLink ?? this.externalLink),
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
